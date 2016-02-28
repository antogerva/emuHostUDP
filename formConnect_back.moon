
import forms, console from _G
import unpackArrValues, dumpPrint from require "utils"

export stuff = {}
export clientConnector = nil
export serverConnector = nil
export cSocket = nil
export sSocket = nil

class FormConnect

  @_isServer = false
  @_isClient = false

  new:()->
    print "new"

  @onClose:()->
    print "close form"
    if cSocket~=nil then
      cSocket\close()
    if sSocket~=nil then
      sSocket\close()

  @setReadOnly:()->
    forms.setproperty(@_txtUdpPort, "ReadOnly", true)
    forms.setproperty(@_txtConnect, "ReadOnly", true)
    forms.setproperty(@_txtUdpPort, "ReadOnly", true)
    forms.setproperty(@_txtConnectPort, "ReadOnly", true)
    forms.setproperty(@_txtUsername, "ReadOnly", true)

  @onStartServerClick:()->
    @_isServer= not @_isServer
    if(@_isServer) then
      forms.setproperty(@_btnStartServer, "Text", "Stop Server")
      print "setup server connector"
      ss = require("server_udp")
      serverConnector = ss.ServerSpawn
      sSocket = ss.serverSocket
      serverConnector\setInputQueue(stuff)
      serverConnector\startTimer()
      serverConnector\setForm(self)
      serverConnector\setBindname("localhost")
      serverConnector\setBindport(forms.getproperty(@_txtUdpPort, "Text"))
      serverConnector\setPeername(forms.getproperty(@_txtConnect, "Text"))
      serverConnector\setPeerport(forms.getproperty(@_txtConnectPort, "Text"))
      serverConnector\setUsername(forms.getproperty(@_txtUsername, "Text"))
      @setReadOnly()
    else
      forms.setproperty(@_btnStartServer, "Text", "Start Server")
      --todo

  @onInvertPortClick:()->
    tmp1 = forms.getproperty(@_txtConnectPort, "Text")
    tmp2 = forms.getproperty(@_txtUdpPort, "Text")
    forms.setproperty(@_txtConnectPort, "Text", tmp2)
    forms.setproperty(@_txtUdpPort, "Text", tmp1)

  @onStartClientClick:()->
    @_isClient= not @_isClient
    if(@_isClient) then
      forms.setproperty(@_btnClientConnect, "Text", "Stop Connect")
      if clientConnector==nil then
        print "setup client connector"
        client_udp= require("client_udp")
        clientConnector = client_udp.ClientSpawn
        cSocket = client_udp.clientSocket

        clientConnector\setBindname("localhost")
        clientConnector\setBindport(forms.getproperty(@_txtUdpPort, "Text"))
        clientConnector\setPeername(forms.getproperty(@_txtConnect, "Text"))
        clientConnector\setPeerport(forms.getproperty(@_txtConnectPort, "Text"))
        clientConnector\setUsername(forms.getproperty(@_txtUsername, "Text"))

        clientConnector\initSocket()

        client_udp.testRun()
        @setReadOnly()
        clientConnector\setForm(self)
        clientConnector\setInputQueue(stuff)
        clientConnector\startTimer()
    else
      forms.setproperty(@_btnClientConnect, "Text", "Client Client")
      --todo
      --require("serverHost")

  addMsgQueue:(self, msg)->
    if clientConnector ~= nil then
      clientConnector\addInputQueue(msg)
      clientConnector\run()
    if serverConnector ~= nil then
      serverConnector\addInputQueue(msg)
      serverConnector\run()

  updateClient:(self, msg)->
    fullMsg = forms.getproperty(@_txtChatBox, "Text")
    fullMsg = fullMsg..msg.."\r\n"
    forms.setproperty(@_txtChatMsg, "Text", "")
    forms.setproperty(@_txtChatBox, "Text", fullMsg)

  @onSendMsgClick:()->
    print("click send msg")
    usrname = forms.getproperty(@_txtUsername, "Text")
    txtMsg = usrname..": "..forms.getproperty(@_txtChatMsg, "Text")
    @addMsgQueue(txtMsg)
    @updateClient(txtMsg)


  @_frmConnect = forms.newform unpackArrValues({(w:320),(h:420),(title:"Chat Box"),(fnClose:@onClose)})

  @_lblConnect = forms.label unpackArrValues({(frm:@_frmConnect), (cap:"Connect to:"), (x:10), (y:10), (w:140), (h:30), (fw:true)})
  @_txtConnect = forms.textbox unpackArrValues({(frm:@_frmConnect),  (cap:"localhost"), (w:140), (h:30), (bt:nil), (x:150), (y:10), (mlt:false), (fw:true), (scroll:"NONE")})

  @_lblConnectPort = forms.label unpackArrValues({(frm:@_frmConnect), (cap:"Connect to UDP:"), (x:10), (y:40), (w:140), (h:30), (fw:true)})
  @_txtConnectPort = forms.textbox unpackArrValues({(frm:@_frmConnect),  (cap:"51425"), (w:140), (h:30), (bt:nil), (x:150), (y:40), (mlt:false), (fw:true), (scroll:"NONE")})

  @_lblUdpPort = forms.label unpackArrValues({(frm:@_frmConnect), (cap:"UDP Port:"), (x:10), (y:70), (w:140), (h:30), (fw:true)})
  @_txtUdpPort = forms.textbox unpackArrValues({(frm:@_frmConnect),  (cap:"51424"), (w:140), (h:30), (bt:nil), (x:150), (y:70), (mlt:false), (fw:true), (scroll:"NONE")})

  @_lblUsername = forms.label unpackArrValues({(frm:@_frmConnect), (cap:"Username:"), (x:10), (y:100), (w:140), (h:30), (fw:true)})
  @_txtUsername = forms.textbox unpackArrValues({(frm:@_frmConnect),  (cap:"MyUsername"), (w:140), (h:30), (bt:nil), (x:150), (y:100), (mlt:false), (fw:true), (scroll:"NONE")})

  @_btnStartServer = forms.button unpackArrValues({(frm:@_frmConnect),  (cap:"Start Server"), (fnClick:@onStartServerClick), (x:10), (y:130), (w:140), (h:30)})
  @_btnClientConnect = forms.button unpackArrValues({(frm:@_frmConnect),  (cap:"Client Connect"), (fnClick:@onStartClientClick), (x:150), (y:130), (w:140), (h:30)})

  @_lblStatus = forms.label unpackArrValues({(frm:@_frmConnect), (cap:"Status:"), (x:10), (y:170), (w:140), (h:30), (fw:true)})
  @_txtStatus = forms.textbox unpackArrValues({(frm:@_frmConnect),  (cap:""), (w:140), (h:30), (bt:nil), (x:150), (y:170), (mlt:false), (fw:true), (scroll:"NONE")})
  forms.setproperty(@_txtStatus, "ReadOnly", true)

  @_txtChatBox = forms.textbox unpackArrValues({(frm:@_frmConnect),  (cap:""), (w:280), (h:100), (bt:nil), (x:10), (y:200), (mlt:true), (fw:true), (scroll:"VERTICAL")})
  forms.setproperty(@_txtChatBox, "ReadOnly", true)

  @_lblChatMsg = forms.label unpackArrValues({(frm:@_frmConnect), (cap:"Chat:"), (x:10), (y:310), (w:50), (h:30), (fw:true)})
  @_txtChatMsg = forms.textbox unpackArrValues({(frm:@_frmConnect),  (cap:""), (w:230), (h:30), (bt:nil), (x:60), (y:310), (mlt:false), (fw:true), (scroll:"NONE")})

  @_btnSendMsg = forms.button unpackArrValues({(frm:@_frmConnect),  (cap:"Send Msg"), (fnClick:@onSendMsgClick), (x:150), (y:340), (w:140), (h:30)})

return {:FormConnect}
