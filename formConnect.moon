
import forms, console from _G
import unpackArrValues, dumpPrint, trim from require "utils"

export inputTbl = {}
export timestampTbl = {}
export clientConnector = nil
export cSocket = nil
export say = nil

class FormConnect
  @_isClient = false

  new:()->
    print "new"

  @onClose:()->
    print "close form"
    if cSocket~=nil then
      cSocket\close()
    return

  setReadOnly:(self)->
    forms.setproperty(@_txtUdpPort, "ReadOnly", true)
    forms.setproperty(@_txtConnect, "ReadOnly", true)
    forms.setproperty(@_txtUdpPort, "ReadOnly", true)
    forms.setproperty(@_txtConnectPort, "ReadOnly", true)
    --forms.setproperty(@_txtUsername, "ReadOnly", true
    forms.setproperty(@_btnInvertPort, "Enabled", false)
    forms.setproperty(@_btnClientConnect, "Enabled", false)
    forms.setproperty(@_txtChatMsg, "ReadOnly", false)
    forms.setproperty(@_btnSendMsg, "Enabled", true)
    return

  @onInvertPortClick:()->
    tmp1 = forms.getproperty(@_txtConnectPort, "Text")..""
    tmp2 = forms.getproperty(@_txtUdpPort, "Text")..""
    forms.setproperty(@_txtConnectPort, "Text", tmp2)
    forms.setproperty(@_txtUdpPort, "Text", tmp1)
    return

  @onStartClientClick:()->
    @_isClient= not @_isClient
    if(@_isClient) then
      forms.setproperty(@_btnClientConnect, "Text", "Stop Connect")
      if clientConnector==nil then
        print "setup client connector"
        client_udp= require("client_udp")
        clientConnector = client_udp.ClientSpawn
        cSocket = client_udp.clientSocket

        bn = "*"
        bp = forms.getproperty(@_txtUdpPort, "Text")
        pn = forms.getproperty(@_txtConnect, "Text")
        pp = forms.getproperty(@_txtConnectPort, "Text")
        usr=forms.getproperty(@_txtUsername, "Text")

        clientConnector\setBindname(trim(bn))
        clientConnector\setBindport(trim(bp))
        clientConnector\setPeername(trim(pn))
        clientConnector\setPeerport(trim(pp))
        clientConnector\initSocket()
        clientConnector\setUsername(trim(usr))
        clientConnector\testRun(inputTbl)

        @setReadOnly()
        clientConnector\setForm(self)
        clientConnector\setInputQueue(inputTbl)
        clientConnector\setTimestampList(timestampTbl)
        clientConnector\startTimer()
    else
      forms.setproperty(@_btnClientConnect, "Text", "Client Client")
    return

  addMsgQueue:(self, msg)->
    if clientConnector ~= nil then
      clientConnector\addInputQueue(msg)
      clientConnector\run()

  updateClient:(self, msg)->
    fullMsg = forms.getproperty(@_txtChatBox, "Text")
    fullMsg = fullMsg..msg.."\r\n"
    forms.setproperty(@_txtChatMsg, "Text", "")
    forms.setproperty(@_txtChatBox, "Text", fullMsg)

  sendMsg:(self, msg)->
    usrname = forms.getproperty(@_txtUsername, "Text")
    txtMsg = usrname..": "..msg
    @addMsgQueue(txtMsg)
    @updateClient(txtMsg)

  updateStatus:(self, newStatus)->
      forms.setproperty(@_txtStatus, "Text", newStatus)

  @onSendMsgClick:()->
    msg=forms.getproperty(@_txtChatMsg, "Text")
    @sendMsg(msg)

  @_frmConnect = forms.newform unpackArrValues({(w:320),(h:420),(title:"Chat Box"),(fnClose:@onClose)})

  @_lblConnect = forms.label unpackArrValues({(frm:@_frmConnect), (cap:"Connect to:"), (x:10), (y:10), (w:140), (h:30), (fw:true)})
  @_txtConnect = forms.textbox unpackArrValues({(frm:@_frmConnect),  (cap:"localhost"), (w:140), (h:30), (bt:nil), (x:150), (y:10), (mlt:false), (fw:true), (scroll:"NONE")})

  @_lblConnectPort = forms.label unpackArrValues({(frm:@_frmConnect), (cap:"Connect to UDP:"), (x:10), (y:40), (w:140), (h:30), (fw:true)})
  @_txtConnectPort = forms.textbox unpackArrValues({(frm:@_frmConnect),  (cap:"51425"), (w:140), (h:30), (bt:nil), (x:150), (y:40), (mlt:false), (fw:true), (scroll:"NONE")})

  @_lblUdpPort = forms.label unpackArrValues({(frm:@_frmConnect), (cap:"UDP Port:"), (x:10), (y:70), (w:140), (h:30), (fw:true)})
  @_txtUdpPort = forms.textbox unpackArrValues({(frm:@_frmConnect),  (cap:"51424"), (w:140), (h:30), (bt:nil), (x:150), (y:70), (mlt:false), (fw:true), (scroll:"NONE")})

  @_lblUsername = forms.label unpackArrValues({(frm:@_frmConnect), (cap:"Username:"), (x:10), (y:100), (w:140), (h:30), (fw:true)})
  @_txtUsername = forms.textbox unpackArrValues({(frm:@_frmConnect),  (cap:"MyUsername"), (w:140), (h:30), (bt:nil), (x:150), (y:100), (mlt:false), (fw:true), (scroll:"NONE")})

  @_btnInvertPort = forms.button unpackArrValues({(frm:@_frmConnect),  (cap:"Invert Port"), (fnClick:@onInvertPortClick), (x:10), (y:130), (w:140), (h:30)})
  @_btnClientConnect = forms.button unpackArrValues({(frm:@_frmConnect),  (cap:"Client Connect"), (fnClick:@onStartClientClick), (x:150), (y:130), (w:140), (h:30)})

  @_lblStatus = forms.label unpackArrValues({(frm:@_frmConnect), (cap:"Status:"), (x:10), (y:170), (w:140), (h:30), (fw:true)})
  @_txtStatus = forms.textbox unpackArrValues({(frm:@_frmConnect),  (cap:"Unknown"), (w:140), (h:30), (bt:nil), (x:150), (y:170), (mlt:false), (fw:true), (scroll:"NONE")})
  forms.setproperty(@_txtStatus, "ReadOnly", true)

  @_txtChatBox = forms.textbox unpackArrValues({(frm:@_frmConnect),  (cap:""), (w:280), (h:100), (bt:nil), (x:10), (y:200), (mlt:true), (fw:true), (scroll:"VERTICAL")})
  forms.setproperty(@_txtChatBox, "ReadOnly", true)

  @_lblChatMsg = forms.label unpackArrValues({(frm:@_frmConnect), (cap:"Chat:"), (x:10), (y:310), (w:50), (h:30), (fw:true)})
  @_txtChatMsg = forms.textbox unpackArrValues({(frm:@_frmConnect),  (cap:""), (w:230), (h:30), (bt:nil), (x:60), (y:310), (mlt:false), (fw:true), (scroll:"NONE")})
  forms.setproperty(@_txtChatMsg, "ReadOnly", true)

  @_btnSendMsg = forms.button unpackArrValues({(frm:@_frmConnect),  (cap:"Send Msg"), (fnClick:@onSendMsgClick), (x:150), (y:340), (w:140), (h:30)})
  forms.setproperty(@_btnSendMsg, "Enabled", false)

say=(msg)->
    FormConnect\sendMsg(msg)

return {:FormConnect, :say}
