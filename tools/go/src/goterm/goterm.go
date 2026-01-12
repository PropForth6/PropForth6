package main

import (
	"bufio"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"time"

	"github.com/jacobsa/go-serial/serial"
	"salsanci.com/propforth/src/chanIp"
	"salsanci.com/propforth/src/serafcFilter"
)

var compileDate, gitRepo, gitHash, gitBranch, versionString string
var toConsole, toLogConsole chan string
var toHost, toSpeedTest, toSpeedEcho, toDataCapture chan []byte

var dataCaptureTimeout, speedTestTimeout time.Duration

var runString string

var testDebug, echoEnable bool

type Profile struct {
	Help                   bool `json:"help"`
	Loopback               bool `json:"loopback"`
	Debug                  bool `json:"debug"`
	ExpandLf               bool `json:"expandLf"`
	ExpandCr               bool `json:"expandCr"`
	SuppressBlankLineDelay bool `json:"suppressBlankLineDelay"`
	FilterHex              bool `json:"filterHex"`
	LogFlag                bool `json:"logFlag"`
	UdpFlag                bool `json:"udpFlag"`
	CrcFlag                bool `json:"crcFlag"`
	XboxController         bool `json:"xboxControllerFlag"`
	XboxControllerDebug    bool `json:"xboxControllerDebugFlag"`
	UseFastMux             bool `json:"useFastMux"`
	AfcFlowControl         bool `json:"afcFlowControl"`

	IpToSerialFlag bool `json:"ipToSerialFlag"`

	TimestampInterval  int64 `json:"timestampInterval"`
	LogHours           int64 `json:"logHours"`
	LineDelayMs        int64 `json:"lineDelayMs"`
	Port               int64 `json:"port"`
	Baud               int64 `json:"baud"`
	MuxPort            int64 `json:"muxPort"`
	NumMux             int64 `json:"numMux"`
	RemotePort         int64 `json:"remotePort"`
	SerialResetTimeout int64 `json:"serialResetTimeout"`

	Name       string `json:"name"`
	LogPrefix  string `json:"logPrefix"`
	DataPrefix string `json:"dataPrefix"`
	SerialPort string `json:"serialPort"`
	Host       string `json:"host"`
	MuxHost    string `json:"muxHost"`
	RemoteHost string `json:"remoteHost"`
	LogDir     string `json:"logDir"`
}

var cc, gg Profile

type Config struct {
	Profiles []Profile
}

var config Config

type StateValue uint8

const (
	IDLE_STATE StateValue = iota
	SPEED_RECEIVE_STATE
	SPEED_ECHO_STATE
	DATA_CAPTURE_STATE
)

var state StateValue

func helpText() string {
	return `



Command line examples:
goterm -serial com9 -baud 230400 (use goterm with a serial port)
goterm -host localhost -port 23 (use goterm to connect to a telnet port)
goterm -port 23 (use goterm listen on port 23)

goterm -serial com9 -baud 230400 -numMux 2 -muxport 2020 (use goterm with a serial port, start muxserver on ports 2020 - 2021) 
goterm -port 23 -numMux 2 -muxhost localhost -muxport 2020 (use goterm to listen on port 23, connect to ports 2020 - 2021 on localhost) 


Terminal commands:(must be at start of a new line and paramaters on the same line)
--help                      - this help
--debugOn                   - turns on debugging
--debugOff                  - turns off debugging
--ipDebugOn                 - turns on debugging for ip channels
--ipDebugOff                - turns off debugging for ip channels
--serDebugOn                - turns on debugging for serial channels
--serDebugOff               - turns off debugging for serial channels
--testDebugOn               - turns on debugging for mux channels
--testDebugOff              - turns on debugging for mux channels
--echoEnable                - enables goterm acting as a speesSend or speedTest client
--echoDisable               - disables goterm acting as a speesSend or speedTest client
--delay x                   - delays input by x milliseconds (default value is 0) 
--speedTest x y z           - runs a speed test with x bytes, blocksize of y bytes (max for udp is 1024), block delay z nanoseconds  (defaults are 1000000 1024 100000)
--timestamp x               - writes a timestamp to the terminal every x minutes, 0 disables timestamp (default value is 0) 
--dataCapture x...z         - captures data from the host port and writes to a file, the rest of the line is sent to the host to initiate data capture
--dataCaptureTimeout x      - terminates data capture after x milli-seconds of inactivity (default is 600) 
--speedEcho                 - remote echo characters for a speedTest (speedTest client)
--speedSend y y z           - runs a speed sending ata only with x bytes, blocksize of y bytes (max for udp is 1024),  block delay z nanoseconds  (defaults are 1000000 1024 100000)
--speedReceive				- receive from speedSend and reports 
--cps x                     - set the transmit rate to x characters per second

Multiplexor protocol:

Used to support multiple logical channels to an fpga or micro over a connection.
Up to 16 channels are supported.

Protocol to / from host:
CN XX...ZZ

C - 4 bits channel number
N - 4 bits number of bytes ( 1 - 15) If crc is specified last 2 bytes are a ccitt crc which include CN
XX...ZZ number of bytes specified by N
`
}

func main() {
	var sp *SerialPort
	var err error
	var timestampInterval, logHours, lineDelayMs, port, baud, muxPort, remotePort, numMux, serialResetTimeout int
	var profile string
	var profileFlag bool
	var configFile string
	var cps uint64

	versionString = "Version 5.0"

	defaultBaud := int(115200)
	runtime.GOMAXPROCS(runtime.NumCPU())

	flag.BoolVar(&cc.Help, "h", false, "Help")
	flag.BoolVar(&cc.Loopback, "l", false, "Loopback mode")
	flag.BoolVar(&cc.Debug, "d", false, "Debug mode")
	flag.BoolVar(&cc.LogFlag, "log", false, "Log to file")
	flag.BoolVar(&cc.UdpFlag, "udp", false, "Use udp instead of tcp")
	flag.BoolVar(&cc.ExpandLf, "lf", false, "Expand LF to CR LF from console")
	flag.BoolVar(&cc.ExpandCr, "cr", false, "Expand CR to CR LF to console")
	flag.BoolVar(&cc.CrcFlag, "crc", false, "Can use crc for multipelxed channels, no effect otherwise")
	flag.BoolVar(&cc.SuppressBlankLineDelay, "suppressBlankLineDelay", true, "Suppress blank line delay, whether to suppress lineDelayMs")
	flag.BoolVar(&cc.XboxController, "xbox", false, "Enable Xbox controller")
	flag.BoolVar(&cc.XboxControllerDebug, "xboxDebug", false, "Enable Xbox controller debug")
	flag.BoolVar(&cc.UseFastMux, "useFastMux", false, "Uses the fast multiplexor")
	flag.BoolVar(&cc.AfcFlowControl, "afcFlowControl", false, "Uses afc flow control")

	flag.BoolVar(&cc.IpToSerialFlag, "ipToSerial", false, "Route ip to serial port")

	flag.IntVar(&serialResetTimeout, "serialResetTimeout", 0, "In milliseconds, reset the serial port if nothing received for n ms")
	flag.IntVar(&baud, "baud", defaultBaud, "Baud rate")
	flag.IntVar(&remotePort, "remotePort", 0, "Remote port, if remote host is not specified console will be available on this port via tcp/ip")
	flag.IntVar(&lineDelayMs, "lineDelay", 0, "Send line delay in milliseconds")
	flag.IntVar(&numMux, "numMux", -1, "Number of multiplexor channels 0, or 2-16")
	flag.IntVar(&logHours, "logHours", 24, "Log hours per file")
	flag.IntVar(&port, "port", -1, "Port")
	flag.IntVar(&muxPort, "muxPort", 2001, "Multiplexor port")
	flag.IntVar(&timestampInterval, "ts", -1, "Timestamp interval (minutes)")

	flag.StringVar(&cc.SerialPort, "serial", "", "Com port for serial communications, Example: \"/dev/serial1\"")
	flag.StringVar(&cc.LogPrefix, "prefix", "", "Log file prefix")
	flag.StringVar(&cc.DataPrefix, "dataPrefix", "", "Data file prefix")
	flag.StringVar(&profile, "p", "", "Profile Name from .goterm.json, search current directory the home directory")
	flag.StringVar(&cc.Host, "host", "", "IP host")
	flag.StringVar(&cc.MuxHost, "muxHost", "", "IP multiplexor host")
	flag.StringVar(&cc.RemoteHost, "remoteHost", "", "Connect to this host and remotePort for console via tcp/ip")
	flag.StringVar(&cc.LogDir, "logDir", "./", "Logging directory")
	flag.Parse()

	cc.SerialResetTimeout = int64(serialResetTimeout)
	cc.TimestampInterval = int64(timestampInterval)
	cc.LogHours = int64(logHours)
	cc.LineDelayMs = int64(lineDelayMs)
	cc.Port = int64(port)
	cc.Baud = int64(baud)
	cc.MuxPort = int64(muxPort)
	cc.NumMux = int64(numMux)
	cc.RemotePort = int64(remotePort)

	speedTestTimeout = 2 * time.Second

	sp = nil
	profileFlag = false

	if len(flag.Args()) > 0 {
		fmt.Printf("\n\nINVALID ARGUMENTS: %v\n\n", flag.Args())
		cc.Help = true
	}
	if profile != "" {
		configFile = "./.goterm.json"
		bv, err := os.ReadFile(configFile)
		if err != nil {
			t, e := os.UserHomeDir()
			if e == nil {
				configFile = t + string(os.PathSeparator) + ".goterm.json"
				bv, err = os.ReadFile(configFile)
			}
		}
		if err != nil {
			fmt.Printf("\nNo .goterm.json file found\n")
		} else {
			json.Unmarshal(bv, &config)
			for i := 0; !profileFlag && i < len(config.Profiles); i++ {
				if config.Profiles[i].Name == profile {
					gg = config.Profiles[i]
					profileFlag = true
				}
			}
		}
		if !profileFlag {
			fmt.Printf("Profile [%s] not found\r\n", profile)
			cc.Help = true
		} else {
			if isFlagSpecified("l") {
				gg.Loopback = cc.Loopback
			}
			if isFlagSpecified("d") {
				gg.Debug = cc.Debug
			}
			if isFlagSpecified("log") {
				gg.LogFlag = cc.LogFlag
			}
			if isFlagSpecified("udp") {
				gg.UdpFlag = cc.UdpFlag
			}
			if isFlagSpecified("lf") {
				gg.ExpandLf = cc.ExpandLf
			}
			if isFlagSpecified("cr") {
				gg.ExpandCr = cc.ExpandCr
			}
			if isFlagSpecified("crc") {
				gg.CrcFlag = cc.CrcFlag
			}
			if isFlagSpecified("xbox") {
				gg.XboxController = cc.XboxController
			}
			if isFlagSpecified("xboxDebug") {
				gg.XboxControllerDebug = cc.XboxControllerDebug
			}
			if isFlagSpecified("useFastMux") {
				gg.UseFastMux = cc.UseFastMux
			}
			if isFlagSpecified("afcFlowControl") {
				gg.AfcFlowControl = cc.AfcFlowControl
			}
			if isFlagSpecified("suppressBlankLineDelay") {
				gg.SuppressBlankLineDelay = cc.SuppressBlankLineDelay
			}
			if isFlagSpecified("ipToSerial") {
				gg.IpToSerialFlag = cc.IpToSerialFlag
			}
			if isFlagSpecified("x") {
				gg.FilterHex = cc.FilterHex
			}

			if isFlagSpecified("serialResetTimeout") {
				gg.SerialResetTimeout = cc.SerialResetTimeout
			}
			if isFlagSpecified("baud") {
				gg.Baud = cc.Baud
			}
			if isFlagSpecified("remotePort") {
				gg.RemotePort = cc.RemotePort
			}
			if isFlagSpecified("lineDelayMs") {
				gg.LineDelayMs = cc.LineDelayMs
			}
			if isFlagSpecified("numMux") {
				gg.NumMux = cc.NumMux
			}
			if isFlagSpecified("logHours") {
				gg.LogHours = cc.LogHours
			}
			if isFlagSpecified("port") {
				gg.Port = cc.Port
			}
			if isFlagSpecified("muxPort") {
				gg.MuxPort = cc.MuxPort
			}
			if isFlagSpecified("ts") {
				gg.TimestampInterval = cc.TimestampInterval
			}

			if isFlagSpecified("serial") {
				gg.SerialPort = cc.SerialPort
			}
			if isFlagSpecified("prefix") {
				gg.LogPrefix = cc.LogPrefix
			}
			if isFlagSpecified("dataPrefix") {
				gg.DataPrefix = cc.DataPrefix
			}
			if isFlagSpecified("host") {
				gg.Host = cc.Host
			}
			if isFlagSpecified("muxHost") {
				gg.MuxHost = cc.MuxHost
			}
			if isFlagSpecified("remoteHost") {
				gg.RemoteHost = cc.RemoteHost
			}
			if isFlagSpecified("logDir") {
				gg.LogDir = cc.LogDir
			}

			cc = gg
		}
	}

	if cc.TimestampInterval <= 0 {
		cc.TimestampInterval = 1000000000
	}

	if cc.NumMux < 2 {
		cc.NumMux = 0
	} else if cc.NumMux > 16 {
		cc.NumMux = 16
	}

	if cc.NumMux == 0 {
		cc.MuxPort = 0
		cc.MuxHost = ""
	} else {
		if cc.MuxPort == 0 {
			cc.Help = true
		}
	}
	if cc.SerialPort == "" && cc.Port <= 0 && !cc.Loopback {
		cc.Help = true
	}
	runString = fmt.Sprintf("goterm compileDate: %s gitRepo: %s gitBranch: %s\ngitHash: %s\nVersion: %s\nhelp: [%v] profile: [%s] ipToSerial: [%v] loopback: [%v] debug: [%v] expandLf: [%v] expandCr: [%v] crc: [%v] filterHex: [%v]\nserialPort: [%v] baud: [%d] serialResetTimeout: %d\nremotePort: [%d] remoteHost: [%s] \nport: [%d] host: [%s] udp: [%v]\ntimestampInterval: [%v] logDir:[%s] logFlag: [%v] logPrefix: [%s] logHours: [%d]\nnumMux: [%d] useFastMux [%v] afcFlowControl [%v]  muxHost: [%s] muxPort: [%d]\nlineDelay: [%d] suppressBlankLineDelay: [%v]\nxBoxController: %v xBoxControllerDebug: %v\n",
		compileDate, gitRepo, gitBranch, gitHash, versionString, cc.Help, profile, cc.IpToSerialFlag, cc.Loopback, cc.Debug, cc.ExpandLf, cc.ExpandCr, cc.CrcFlag, cc.FilterHex, cc.SerialPort, cc.Baud, cc.SerialResetTimeout, cc.RemotePort, cc.RemoteHost, cc.Port, cc.Host, cc.UdpFlag, cc.TimestampInterval, cc.LogDir, cc.LogFlag, cc.LogPrefix, cc.LogHours, cc.NumMux, cc.UseFastMux, cc.AfcFlowControl, cc.MuxHost, cc.MuxPort, cc.LineDelayMs, cc.SuppressBlankLineDelay, cc.XboxController, cc.XboxControllerDebug)
	fmt.Printf("%s", runString)
	if cc.Help {
		fmt.Printf("\nConfig File [%s]   Valid profiles:\n", configFile)
		for i := 0; i < len(config.Profiles); i++ {
			fmt.Printf("  [%s]\n", config.Profiles[i].Name)
		}
		fmt.Printf("\n")

		fmt.Printf("goterm:\n%s", helpText())
		fmt.Printf("\nCommand line switches:\n")
		flag.PrintDefaults()
	} else {
		dataCaptureTimeout = 600
		fromConsole := make(chan string)
		toConsole = make(chan string, 100)
		toLogConsole = make(chan string, 100)
		toSpeedTest = make(chan []byte)
		toSpeedEcho = make(chan []byte, 100000)
		toDataCapture = make(chan []byte, 1000)

		toHost = make(chan []byte, 2)
		fromHost := make(chan []byte, 1)
		toPhy := make(chan []byte, 2)
		fromPhy := make(chan []byte, 1)
		ipToSerialFromSerial := make(chan []byte, 100)
		ipToSerialToSerial := make(chan []byte, 100)
		errChan := make(chan string, 100)

		chanIp.Debug = cc.Debug
		chanIp.LogChan = toLogConsole
		serafcFilter.Debug = cc.Debug
		serafcFilter.LogChan = toLogConsole

		if cc.NumMux <= 1 {
			if !cc.AfcFlowControl {
				go func() {
					for {
						t := <-toHost
						if len(t) > 0 {
							toPhy <- t
						}
					}
				}()
				go func() {
					for {
						t := <-fromPhy
						if len(t) > 0 {
							fromHost <- t
						}
					}
				}()
			} else {
				toAfc := make(chan []byte, 2)
				fromAfc := make(chan []byte, 1)

				serafcFilter.AfcFilter(fromPhy, toPhy, fromAfc, toAfc)
				go func() {
					for {
						t := <-toHost
						if len(t) > 0 {
							toAfc <- t
						}
					}
				}()
				go func() {
					for {
						t := <-fromAfc
						if len(t) > 0 {
							fromHost <- t
						}
					}
				}()
			}
		} else {
			if !cc.AfcFlowControl {
				if cc.UseFastMux {
					go fastMultiplexor(fromHost, toHost, fromPhy, toPhy, errChan, int(cc.NumMux), int(cc.MuxPort), cc.MuxHost, cc.XboxController, cc.XboxControllerDebug)
				} else {
					go multiplexor(fromHost, toHost, fromPhy, toPhy, errChan, int(cc.NumMux), int(cc.MuxPort), cc.MuxHost, cc.CrcFlag, cc.XboxController, cc.XboxControllerDebug)
				}
			} else {
				toAfc := make(chan []byte, 2)
				fromAfc := make(chan []byte, 1)

				serafcFilter.AfcFilter(fromPhy, toPhy, fromAfc, toAfc)
				go func() {
					for {
						t := <-toHost
						if len(t) > 0 {
							toAfc <- t
						}
					}
				}()
				go func() {
					for {
						t := <-fromAfc
						if len(t) > 0 {
							fromHost <- t
						}
					}
				}()
				if cc.UseFastMux {
					go fastMultiplexor(fromHost, toHost, fromAfc, toAfc, errChan, int(cc.NumMux), int(cc.MuxPort), cc.MuxHost, cc.XboxController, cc.XboxControllerDebug)
				} else {
					go multiplexor(fromHost, toHost, fromAfc, toAfc, errChan, int(cc.NumMux), int(cc.MuxPort), cc.MuxHost, cc.CrcFlag, cc.XboxController, cc.XboxControllerDebug)
				}
			}
		}

		go func() {
			lastS := ""
			s := ""
			for {
				count := 1
				for flag := true; flag; {
					select {
					case s = <-errChan:
						if s == lastS {
							count++
						} else {
							lastS = s
							flag = false
						}
					case <-time.After(time.Duration(100) * time.Millisecond):
						lastS = ""
						flag = false
					}
				}
				if lastS != "" {
					toLogConsole <- fmt.Sprintf("\r\n\nERROR [%s][%s] COUNT: %d\r\n\n", time.Now().Local(), lastS, count)
				}
			}
		}()

		go func() {
			for {
				c := <-toLogConsole
				toConsole <- fmt.Sprintf("GOTERM: %-40s %s\r\n", time.Now().Local(), c)
			}
		}()

		if cc.RemotePort == int64(0) {
			go getConsole(fromConsole)
			go putConsole(toConsole)
		} else {
			go putConsole(toLogConsole)

			toRemoteConsole := make(chan []byte, 100)
			fromRemoteConsole := make(chan []byte, 100)
			fromRemoteByte := make(chan byte, 1000)

			go func() {
				for {
					s := <-toConsole
					toRemoteConsole <- []byte(s)
				}
			}()

			go func() {
				for {
					s := <-fromRemoteConsole
					for _, c := range s {
						fromRemoteByte <- c
					}
				}
			}()

			go func() {
				b := []byte{}
				for {
					c := <-fromRemoteByte
					b = append(b, c)
					if c == byte(0xA) || c == byte(0xD) {
						fromConsole <- string(b)
						b = []byte{}
					}
				}
			}()

			if cc.RemoteHost == "" {
				if cc.UdpFlag {
					go chanIp.ListenUdp(int(cc.RemotePort), toRemoteConsole, fromRemoteConsole)
				} else {
					go chanIp.Listen(int(cc.RemotePort), toRemoteConsole, fromRemoteConsole)
				}
			} else {
				if cc.UdpFlag {
					go chanIp.ConnectUdp(cc.RemoteHost, int(cc.RemotePort), toRemoteConsole, fromRemoteConsole)
				} else {
					go chanIp.Connect(cc.RemoteHost, int(cc.RemotePort), toRemoteConsole, fromRemoteConsole)
				}
			}
		}

		if (cc.Port != -1 || cc.Loopback) && cc.Baud == int64(defaultBaud) {
			cc.Baud = 10000000000
		}

		ok := true
		if cc.Loopback {
			toLogConsole <- "goterm: LOOPBACK MODE"
			go func() {
				for {
					fs := <-toPhy
					rb := make([]byte, len(fs))
					copy(rb, fs)
					if cc.Debug {
						toLogConsole <- fmt.Sprintf("Loopback: SEND %d bytes [%v]", len(rb), formatHex(rb))
					}
					fromPhy <- rb
				}
			}()
		} else if cc.IpToSerialFlag && (cc.SerialPort != "") && (cc.Port != 0) {
			sp, err = NewSerial(cc.SerialPort, uint(cc.Baud), ipToSerialFromSerial, ipToSerialToSerial, uint(cc.SerialResetTimeout))
			if err != nil {
				toLogConsole <- fmt.Sprintf("goterm: serial ERROR [%v]", err)
				time.Sleep(500 * time.Millisecond)
				ok = false
			} else {
				if cc.Host == "" {
					toConsole <- "goterm: IP HOST MODE"
					if cc.UdpFlag {
						go chanIp.ListenUdp(int(cc.Port), ipToSerialFromSerial, ipToSerialToSerial)
					} else {
						go chanIp.Listen(int(cc.Port), ipToSerialFromSerial, ipToSerialToSerial)
					}
				} else {
					toLogConsole <- "goterm: IP CLIENT MODE"
					if cc.UdpFlag {
						go chanIp.ConnectUdp(cc.Host, int(cc.Port), ipToSerialFromSerial, ipToSerialToSerial)
					} else {
						go chanIp.Connect(cc.Host, int(cc.Port), ipToSerialFromSerial, ipToSerialToSerial)
					}
				}
				toLogConsole <- "goterm: SERIAL MODE IpToSerial"
				sp.SetDebug(cc.Debug)
				sp.SetLog(toLogConsole)
			}

		} else if cc.SerialPort != "" {
			sp, err = NewSerial(cc.SerialPort, uint(cc.Baud), fromPhy, toPhy, uint(cc.SerialResetTimeout))
			if err != nil {
				toLogConsole <- fmt.Sprintf("goterm: serial ERROR [%v]", err)
				time.Sleep(500 * time.Millisecond)
				ok = false
			} else {
				toLogConsole <- "goterm: SERIAL MODE"
				sp.SetDebug(cc.Debug)
				sp.SetLog(toLogConsole)
			}
		} else if cc.Port != -1 {
			if cc.Host == "" {
				toConsole <- "goterm: IP HOST MODE"
				if cc.UdpFlag {
					go chanIp.ListenUdp(int(cc.Port), toPhy, fromPhy)
				} else {
					go chanIp.Listen(int(cc.Port), toPhy, fromPhy)
				}
			} else {
				toLogConsole <- "goterm: IP CLIENT MODE"
				if cc.UdpFlag {
					go chanIp.ConnectUdp(cc.Host, int(cc.Port), toPhy, fromPhy)
				} else {
					go chanIp.Connect(cc.Host, int(cc.Port), toPhy, fromPhy)
				}
			}
		} else {
			ok = false
		}

		if ok {
			go func() {
				for {
					fs := <-fromHost
					rb := make([]byte, len(fs))
					copy(rb, fs)

					switch state {
					case IDLE_STATE:
						if len(rb) > 0 {
							toConsole <- string(rb)
						}
					case SPEED_RECEIVE_STATE:
						toSpeedTest <- rb
					case SPEED_ECHO_STATE:
						toSpeedEcho <- rb
					case DATA_CAPTURE_STATE:
						toDataCapture <- rb
					}
				}
			}()

			for {
				fc := <-fromConsole
				fe := strings.Fields(fc)
				if len(fe) == 0 {
					toHost <- []byte(fc)
				} else {
					switch fe[0] {
					case "--help":
						toConsole <- helpText()
					case "--debugOn":
						if sp != nil {
							sp.SetDebug(true)
						}
						chanIp.Debug = true
						cc.Debug = true
					case "--debugOff":
						if sp != nil {
							sp.SetDebug(false)
						}
						chanIp.Debug = false
						cc.Debug = false
					case "--ipDdebugOn":
						chanIp.Debug = true
					case "--ipDebugOff":
						chanIp.Debug = false
					case "--serDebugOn":
						if sp != nil {
							sp.SetDebug(true)
						}
					case "--serDebugOff":
						if sp != nil {
							sp.SetDebug(false)
						}
					case "--testDebugOn":
						testDebug = true
					case "--testDebugOff":
						testDebug = false
					case "--echoEnable":
						echoEnable = true
					case "--echoDisable":
						echoEnable = false
					case "--timestamp":
						interval := uint64(0)
						if len(fe) > 1 {
							interval = getUint(fe[1], interval)
						}
						cc.TimestampInterval = int64(interval)
					case "--delay":
						immediateDelay := uint64(0)
						if len(fe) > 1 {
							immediateDelay = getUint(fe[1], immediateDelay)
						}
						if immediateDelay > 0 {
							time.Sleep(time.Duration(immediateDelay) * time.Millisecond)
						}
					case "--cps":
						cps = getUint(fe[1], cps)
					case "--dataCaptureTimeout":
						timeout := uint64(600)
						if len(fe) > 1 {
							dataCaptureTimeout = time.Duration(getUint(fe[1], timeout) * uint64(time.Millisecond))
						}
					case "--dataCapture":
						if len(fc) > len(fe[0]) {
							tt := strings.Trim(fc[len(fe[0]):], "\r\n\t ") + "\n"
							go dataCapture()
							if len(tt) > 0 {
								toHost <- []byte(tt)
							}
						}
					case "--speedSend":
						total := uint64(1000000)
						block := uint64(1024)
						delay := uint64(100000)
						if len(fe) > 1 {
							total = getUint(fe[1], total)
						}
						if len(fe) > 2 {
							block = getUint(fe[2], block)
						}
						if len(fe) > 3 {
							delay = getUint(fe[3], delay)
						}
						toHost <- []byte("!!speedReceive%%speedReceive$$speedReceive!!\n")
						go func() {
							time.Sleep(time.Second)
							speedSend(uint(total), uint(block), uint(delay))
						}()
					case "--speedTest":
						total := uint64(1000000)
						block := uint64(1024)
						delay := uint64(100000)
						if len(fe) > 1 {
							total = getUint(fe[1], total)
						}
						if len(fe) > 2 {
							block = getUint(fe[2], block)
						}
						if len(fe) > 3 {
							delay = getUint(fe[3], delay)
						}
						toHost <- []byte("!!speedEcho%%speedEcho$$speedEcho!!\n")
						go speedSend(uint(total), uint(block), uint(delay))
						go speedReceive()
					default:
						changeState(IDLE_STATE)
						toHost <- []byte(fc)
						if cps > 0 {
							cpsDelay := (time.Second * time.Duration(len(fc))) / time.Duration(cps)
							time.Sleep(cpsDelay)
						}
					}
				}
			}
		}
	}
}

func stateToString(n StateValue) string {
	rc := "?????"
	switch n {
	case IDLE_STATE:
		rc = "IDLE_STATE"
	case SPEED_RECEIVE_STATE:
		rc = "SPEED_RECEIVE_STATE"
	case SPEED_ECHO_STATE:
		rc = "SPEED_ECHO_STATE"
	case DATA_CAPTURE_STATE:
		rc = "DATA_CAPTURE_STATE"
	}
	return rc
}

func changeState(n StateValue) {
	if state != n {
		toLogConsole <- fmt.Sprintf("%s -> %s", stateToString(state), stateToString(n))
		state = n
	}
}

func isFlagSpecified(n string) bool {
	rc := false
	flag.Visit(func(f *flag.Flag) {
		if f.Name == n {
			rc = true
		}
	})
	return rc
}

func getUint(s string, def uint64) uint64 {
	var rc uint64
	rc = def
	vv, e := strconv.ParseUint(string(s), 0, 32)
	if e != nil {
		toConsole <- fmt.Sprintf("goterm: Invalid number [%s]\n", s)
	} else {
		rc = vv
	}
	return rc
}

func dataCapture() {
	t := time.Now()
	name := fmt.Sprintf("%s_%04d_%02d_%02d__%02d_%02d_%02d.data", cc.DataPrefix, t.Year(), t.Month(), t.Day(), t.Hour(), t.Minute(), t.Second())
	f, err := os.OpenFile(name, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	captureSize := 0
	if err != nil {
		toConsole <- fmt.Sprintf("\r\ngoterm_dataCaptureFileOpen: [%s][%v]\r\n", name, err)
	} else {
		changeState(DATA_CAPTURE_STATE)
		toConsole <- fmt.Sprintf("\r\ngoterm_dataCaptureStarted: file:[%s] dataCaptureTimeout(ms):[%d]\r\n", name, dataCaptureTimeout)
		for flag := true; flag; {
			select {
			case d := <-toDataCapture:
				_, err = f.Write(d)
				captureSize += len(d)
				if err != nil {
					toConsole <- fmt.Sprintf("\r\ngoterm_dataFileWrite: [%s][%v]\r\n", name, err)
					flag = false
				}
			case <-time.After(dataCaptureTimeout):
				flag = false
			}
		}
		f.Close()
		toConsole <- fmt.Sprintf("\r\ngoterm_dataCaptureDone: [%s] size:[%d]\r\n", name, captureSize)
		changeState(IDLE_STATE)
	}
}

func speedEcho() {
	changeState(SPEED_ECHO_STATE)
	toLogConsole <- "   speedEcho wait"
	time.Sleep(speedTestTimeout / 8)
	for flag := true; flag; {
		select {
		case <-toSpeedTest:
		default:
			flag = false
		}
	}
	toLogConsole <- "   speedEcho start"

	receivedBytes := int(0)
	recStart := time.Now()
	recTime := time.Duration(0)
	firstRec := false
	for f := true; f; {
		select {
		case buf := <-toSpeedEcho:
			if !firstRec {
				firstRec = true
				recStart = time.Now()
			}
			recTime = time.Since(recStart)
			receivedBytes += len(buf)
			qbuf := make([]byte, len(buf))
			copy(qbuf, buf)
			toHost <- qbuf
		case <-time.After(speedTestTimeout):
			f = false
		}
	}
	rcps := 1000 * float64(receivedBytes) / float64(recTime.Milliseconds())
	toLogConsole <- fmt.Sprintf("speedEcho done: #chars: %4.2e recCPS: %4.2e recTime: %v", float64(receivedBytes), rcps, recTime)
	changeState(IDLE_STATE)
}

func speedSend(s, sz, delay uint) {
	var sendStart, lastLog time.Time
	var sendTime time.Duration

	speedSendStartTime := time.Now()
	toLogConsole <- "   speedSend wait"
	logInterval := time.Duration(10 * time.Second)
	t := make([]byte, s)
	sf := float64(s)
	c := byte(0x20)
	for i := 0; i < len(t); i++ {
		t[i] = c
		c++
		if c > byte(0x7E) {
			c = byte(0x20)
		}
	}
	td := time.Duration(delay)

	elapsed := time.Since(speedSendStartTime.Add(speedTestTimeout / 4))
	if elapsed < 0 {
		time.Sleep(-elapsed)
	}

	toLogConsole <- fmt.Sprintf("   speedSend start: %4.2e bytes -- Send block size: %4.4e Block delay: %d nS", float64(s), float64(sz), delay)
	sendStart = time.Now()
	lastLog = sendStart
	for i := uint(0); int(i) < len(t); i += sz {
		//	for i := uint(0); int(i) < len(t) && state == SPEED_TEST_STATE; i += sz {
		if time.Since(lastLog) > time.Duration(logInterval) {
			toLogConsole <- fmt.Sprintf("   speedSend: %4.2f%% of bytes sent", 100*float64(i)/float64(s))
			lastLog = time.Now()
		}
		if i+sz >= uint(len(t)) {
			toHost <- t[i:]
		} else {
			toHost <- t[i : i+sz]
		}
		sendTime = time.Since(sendStart)
		time.Sleep(td)
	}
	scps := 1000 * sf / float64(sendTime.Milliseconds())
	toLogConsole <- fmt.Sprintf("   speedSend done: #chars: %4.2e sendCPS: %4.2e sendTime: %v", sf, scps, sendTime)
}
func speedReceive() {
	changeState(SPEED_RECEIVE_STATE)
	toLogConsole <- "speedReceive wait"

	receiveErrorCount := 0
	totalReceiveErrorCount := 0

	c := byte(0x20)
	receivedBytes := int(0)

	logInterval := time.Duration(10 * time.Second)
	firstRec := false

	time.Sleep(speedTestTimeout / 8)
	buf := []byte{}
	for flag := true; flag; {
		select {
		case t := <-toSpeedTest:
			buf = append(buf, t...)
		case <-time.After(10 * time.Millisecond):
			flag = false
		}
	}
	toLogConsole <- string(buf)

	recStart := time.Now()
	recTime := time.Since(recStart)
	lastLog := recStart

	for state == SPEED_RECEIVE_STATE {
		select {
		case rb := <-toSpeedTest:
			if testDebug {
				toLogConsole <- fmt.Sprintf("SpeedReceive: %d %s", len(rb), formatHex(rb))
			}
			if !firstRec {
				recStart = time.Now()
				firstRec = true
				toLogConsole <- fmt.Sprintf("speedReceive start: %d bytes received", len(rb))
			}
			recTime = time.Since(recStart)
			receivedBytes += len(rb)
			if time.Since(lastLog) > time.Duration(logInterval) {
				toLogConsole <- fmt.Sprintf("speedReceive: %4.2e bytes received", float64(receivedBytes))
				lastLog = time.Now()
			}
			for i := 0; receiveErrorCount < 200 && i < len(rb); i++ {
				if rb[i] != c {
					toLogConsole <- fmt.Sprintf("speedReceive: data error: receivedBytes [%d] pos [%d] expected [%02X][%c] actual [%02X][%c]", receivedBytes, i, c, c, rb[i], rb[i])
					receiveErrorCount++
					totalReceiveErrorCount++
					c = rb[i]
					if receiveErrorCount >= 199 {
						go func() {
							time.Sleep(speedTestTimeout)
							receiveErrorCount = 0
						}()
					}
				}
				c++
				if c > byte(0x7E) {
					c = byte(0x20)
				}
			}
		case <-time.After(speedTestTimeout):
			if testDebug {
				toLogConsole <- fmt.Sprintf("SpeedReceive: %v", speedTestTimeout)
			}
			changeState(IDLE_STATE)
			//			toHost <- []byte{byte(0x0d)}
		}
	}
	rcps := 1000 * float64(receivedBytes) / float64(recTime.Milliseconds())
	toLogConsole <- fmt.Sprintf("speedReceive done: #chars: %4.2e errorCount: %d recCPS: %4.2e recTime: %v", float64(receivedBytes), receiveErrorCount, rcps, recTime)
}

func isBlankLine(s string) bool {
	rc := true
	for i := 0; rc && i < len(s); i++ {
		if s[i] != byte(0x09) && s[i] != byte(0x0a) && s[i] != byte(0x0d) && s[i] != byte(0x20) {
			rc = false
		}
	}
	return rc
}

func getConsole(c chan string) string {
	reader := bufio.NewReader(os.Stdin)
	for {
		text, err := reader.ReadString('\n')
		if err != nil {
			toConsole <- fmt.Sprintf("\r\ngoterm: %s Console read ERROR [%s]\r\n", time.Now().Local(), err.Error())
		} else {
			if cc.ExpandLf {
				text = strings.ReplaceAll(text, "\n", "\r\n")
			}
			c <- text
			if cc.LineDelayMs > 0 && (!isBlankLine(text) || !cc.SuppressBlankLineDelay) {
				time.Sleep(time.Duration(cc.LineDelayMs) * time.Millisecond)
			}
		}
	}
}
func putConsole(c chan string) string {
	go func() {
		mc := int64(0)
		for {
			<-time.After(time.Minute)
			mc++
			if mc >= cc.TimestampInterval {
				mc = 0
				toConsole <- fmt.Sprintf("\r\ngoterm_timestamp: %s\r\n", time.Now().Local())
			}
		}
	}()

	var f *os.File
	var err error
	var name string

	logStart := time.Now()

	if cc.LogFlag {
		t := time.Now()
		logStart = t
		name = filepath.Join(cc.LogDir, fmt.Sprintf("%s_%04d_%02d_%02d__%02d_%02d_%02d.log", cc.LogPrefix, t.Year(), t.Month(), t.Day(), t.Hour(), t.Minute(), t.Second()))
		f, err = os.OpenFile(name, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
		if err != nil {
			toConsole <- fmt.Sprintf("\r\ngoterm_logFileOpen: [%s][%v]\r\n", name, err)
			cc.LogFlag = false
		} else {
			_, err = f.Write([]byte(runString))
			if err != nil {
				toConsole <- fmt.Sprintf("\r\ngoterm_logFileWrite: [%s][%v]\r\n", name, err)
				cc.LogFlag = false
			}

		}
	}
	for {
		text := <-c
		if cc.ExpandCr {
			text = strings.ReplaceAll(text, "\r", "\r\n")
		}
		if echoEnable && strings.Contains(text, "!!speedReceive%%speedReceive$$speedReceive!!") {
			text = ""
			go speedReceive()
		} else if echoEnable && strings.Contains(text, "!!speedEcho%%speedEcho$$speedEcho!!") {
			text = ""
			go speedEcho()
		} else if strings.Contains(text, "!!dataCapture%%dataCapture$$dataCapture!!") {
			go dataCapture()
		}
		if cc.LogFlag {
			_, err = f.Write([]byte(text))
			if err != nil {
				toConsole <- fmt.Sprintf("\r\ngoterm_logFileWrite: [%s][%v]\r\n", name, err)
				cc.LogFlag = false
			} else {
				if time.Since(logStart) > time.Duration(time.Hour*time.Duration(cc.LogHours)) {
					err = f.Close()
					if err != nil {
						toConsole <- fmt.Sprintf("\r\ngoterm_logFileClose: [%s][%v]\r\n", name, err)
						cc.LogFlag = false
					}
					t := time.Now()
					name = filepath.Join(cc.LogDir, fmt.Sprintf("%s_%04d_%02d_%02d__%02d_%02d_%02d.log", cc.LogPrefix, t.Year(), t.Month(), t.Day(), t.Hour(), t.Minute(), t.Second()))
					f, err = os.OpenFile(name, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
					if err != nil {
						toConsole <- fmt.Sprintf("\r\ngoterm_logFileOpen: [%s][%v]\r\n", name, err)
						cc.LogFlag = false
					}
					logStart = t
				}
			}
		}
		if cc.FilterHex {
			t := make([]byte, len(text)*4)
			dst := 0
			for src := 0; src < len(text); src++ {
				ch := byte(text[src])
				if ch == byte(0x08) || ch == byte(0x09) || ch == byte(0x0a) || ch == byte(0x0d) || (ch >= byte(0x20) && ch <= byte(0x7f)) {
					t[dst] = ch
					dst++
				} else {
					tx := fmt.Sprintf("\\x%02X", ch)
					t[dst] = tx[0]
					dst++
					t[dst] = tx[1]
					dst++
					t[dst] = tx[2]
					dst++
					t[dst] = tx[3]
					dst++
				}
			}
			text = string(t[:dst])
		}
		fmt.Printf("%s", text)
	}
}

// SerialPort - Provides data transfer through a serial port
type SerialPort struct {
	port                           io.ReadWriteCloser
	baud, serialResetTimeout       uint
	debug                          bool
	rxExit, txExit, rxDone, txDone chan bool
	inCh                           chan<- []byte
	outCh                          <-chan []byte
	log                            chan<- string
	options                        serial.OpenOptions
}

func NewSerial(portName string, baudrate uint, inputCh chan<- []byte, outputCh <-chan []byte, serialResetTimeoutMs uint) (*SerialPort, error) {
	var e error
	s := new(SerialPort)
	s.inCh = inputCh
	s.outCh = outputCh
	s.rxExit = make(chan bool)
	s.txExit = make(chan bool)
	s.rxDone = make(chan bool)
	s.txDone = make(chan bool)
	s.serialResetTimeout = serialResetTimeoutMs
	s.baud = baudrate
	s.options = serial.OpenOptions{
		PortName: portName,
		BaudRate: baudrate,
		DataBits: 8,
		StopBits: 1,
		////InterCharacterTimeout: 100,
		//MinimumReadSize:   1,
		InterCharacterTimeout: 100,
		MinimumReadSize:       0,
		RTSCTSFlowControl:     false,
	}

	if portName != "" {
		s.port, e = serial.Open(s.options)
	} else {
		e = errors.New("blank serial port name")
	}
	if e == nil {
		go s.run()
	}
	return s, e
}
func (s *SerialPort) run() {
	done := make(chan bool, 1)
	for {
		go s.doReceive()
		go s.doSend()
		go func() {
			for {
				select {
				case <-s.txDone:
					s.rxExit <- true
				case <-s.rxDone:
					s.txExit <- true
				}
				done <- true
			}
		}()
		<-done
		time.Sleep(time.Second)
		s.Close()
		wait := 1
		var e error
		if s.log != nil {
			s.log <- "Serial port run: closed"
		}
		for f := true; f; {
			time.Sleep(time.Second * time.Duration(wait))
			if wait < 15 {
				wait++
			}
			if s.log != nil {
				s.log <- "Serial port run: reopening"
			}
			s.port, e = serial.Open(s.options)
			if e != nil {
				if s.log != nil {
					s.log <- fmt.Sprintf("Serial port run: reopening failed [%v]", e)
				}
			} else {
				f = false
				if s.log != nil {
					s.log <- "Serial port run: reopened"
				}
			}
		}
	}
}
func (s *SerialPort) SetLog(l chan<- string) {
	if s.port != nil {
		s.log = l
	}
}
func (s *SerialPort) Close() {
	if s.port != nil {
		s.port.Close()
	}
}

func (s *SerialPort) SetDebug(t bool) {
	s.debug = t
}
func (s *SerialPort) GetDebug() bool {
	return s.debug
}

func (s *SerialPort) doReceive() {
	var err error
	var n, cn int

	buf := make([]byte, 40000)
	lastRec := time.Now()

	for f := true; f; {
		n = 0
		cn, err = s.port.Read(buf[n:])
		n += cn
		for i := 0; f && i < 16 && cn < 8 && err == nil; {
			cn, err = s.port.Read(buf[n:])
			n += cn
			if cn <= 1 && err == nil {
				time.Sleep(100 * time.Microsecond)
			}
			if n > 0 {
				i++
			}
		}
		// if s.log != nil && (n > 0 || err != nil) {
		// 	s.log <- fmt.Sprintf("doReceive: %d [%v]", n, err)
		// }

		select {
		case <-s.txExit:
			f = false
		default:
		}
		if s.serialResetTimeout > 0 && time.Since(lastRec) > time.Millisecond*time.Duration(s.serialResetTimeout) {
			f = false
		}
		if f {
			if n > 0 {
				recBuf := make([]byte, n)
				copy(recBuf, buf[0:n])
				s.inCh <- recBuf
				lastRec = time.Now()
				if s.debug && s.log != nil {
					s.log <- fmt.Sprintf("doReceive: SERIAL RECEIVED [%v][%v] %d bytes [%v]", err, lastRec, n, formatHex(recBuf))
				}
			}

			if err != nil && err != io.EOF {
				if s.log != nil {
					s.log <- fmt.Sprintf("doReceive: SERIAL RECEIVE ERROR [%v], exiting", err)
				}
				f = false
			}
			//if err == io.EOF {
			//	if s.log != nil {
			//		s.log <- fmt.Sprintf("doReceive: SERIAL EOF\n")
			//	}
			//	f = false
			//} else if err != nil {
			//	if s.log != nil {
			//		s.log <- fmt.Sprintf("\r\ndoReceive: SERIAL RECEIVE ERROR [%v], exiting\r\n", err)
			//	}
			//	f = false
			//}
		}
		// time.Sleep(time.Millisecond)
	}
	if s.log != nil {
		s.log <- "doReceive: SERIAL exiting"
	}
	s.rxDone <- true
}

func (s *SerialPort) doSend() {
	for f := true; f; {
		select {
		case val := <-s.outCh:
			n := len(val)
			buf := make([]byte, n)
			copy(buf, val)
			for n := 0; n < len(buf); {
				sz := len(buf) - n
				if sz > 10000 {
					sz = 10000
				}
				sendBuf := buf[n : n+sz]
				n += sz
				if s.debug && s.log != nil {
					s.log <- fmt.Sprintf("doSend: SERIAL SENT %d bytes [%v]", n, formatHex(sendBuf))
				}
				pauseTime := time.Duration(1.05 * float64(time.Second) * float64(len(sendBuf)*10) / float64(s.baud))
				nt := time.NewTimer(pauseTime).C
				n, err := s.port.Write(sendBuf)
				// if s.log != nil {
				// 	ms := float64(pauseTime) / 1000000.0
				// 	s.log <- fmt.Sprintf("doSend: %d [%f] [%v]", n, ms, err)
				// }
				<-nt
				if err != nil {
					if s.log != nil {
						s.log <- fmt.Sprintf("doSend: SERIAL SEND ERROR [%v]", err)
					}
					f = false
				} else if n != len(sendBuf) {
					if s.log != nil {
						s.log <- fmt.Sprintf("doSend: SERIAL SEND ERROR sent[%v] of [%v]", n, len(sendBuf))
					}
					f = false
				}
			}
		case <-s.txExit:
			if s.debug && s.log != nil {
				s.log <- "doSend: SERIAL SEND - Exit request received, exiting send"
			}
			f = false
		}
	}
	s.txDone <- true
}
func formatHex(b []byte) string {
	s := "["
	t := "["
	for i := 0; i < len(b); i++ {
		s += fmt.Sprintf("0x%02X ", b[i])
		if b[i] >= 0x20 && b[i] <= 0x7E {
			t += fmt.Sprintf("%c", b[i])
		} else {
			t += "."
		}
		if (i % 4) == 3 {
			s += "  "
			t += " "
		}
	}
	s += "]"
	t += "]"
	return s + t
}
