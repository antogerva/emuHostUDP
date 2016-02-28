local forms, console
do
  local _obj_0 = _G
  forms, console = _obj_0.forms, _obj_0.console
end
local unpackArrValues, dumpPrint
do
  local _obj_0 = require("utils")
  unpackArrValues, dumpPrint = _obj_0.unpackArrValues, _obj_0.dumpPrint
end
inputTbl = { }
clientConnector = nil
cSocket = nil
say = nil
local FormConnect
do
  local _class_0
  local _base_0 = {
    setReadOnly = function(self)
      forms.setproperty(self._txtUdpPort, "ReadOnly", true)
      forms.setproperty(self._txtConnect, "ReadOnly", true)
      forms.setproperty(self._txtUdpPort, "ReadOnly", true)
      forms.setproperty(self._txtConnectPort, "ReadOnly", true)
      forms.setproperty(self._btnInvertPort, "Enabled", false)
      forms.setproperty(self._btnClientConnect, "Enabled", false)
      forms.setproperty(self._txtChatMsg, "ReadOnly", false)
      forms.setproperty(self._btnSendMsg, "Enabled", true)
    end,
    addMsgQueue = function(self, msg)
      if clientConnector ~= nil then
        clientConnector:addInputQueue(msg)
        return clientConnector:run()
      end
    end,
    updateClient = function(self, msg)
      local fullMsg = forms.getproperty(self._txtChatBox, "Text")
      fullMsg = fullMsg .. msg .. "\r\n"
      forms.setproperty(self._txtChatMsg, "Text", "")
      return forms.setproperty(self._txtChatBox, "Text", fullMsg)
    end,
    sendMsg = function(self, msg)
      local usrname = forms.getproperty(self._txtUsername, "Text")
      local txtMsg = usrname .. ": " .. msg
      self:addMsgQueue(txtMsg)
      return self:updateClient(txtMsg)
    end,
    updateStatus = function(self, newStatus)
      return forms.setproperty(self._txtStatus, "Text", newStatus)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function()
      return print("new")
    end,
    __base = _base_0,
    __name = "FormConnect"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self._isClient = false
  self.onClose = function()
    print("close form")
    if cSocket ~= nil then
      cSocket:close()
    end
  end
  self.onInvertPortClick = function()
    local tmp1 = forms.getproperty(self._txtConnectPort, "Text") .. ""
    local tmp2 = forms.getproperty(self._txtUdpPort, "Text") .. ""
    forms.setproperty(self._txtConnectPort, "Text", tmp2)
    forms.setproperty(self._txtUdpPort, "Text", tmp1)
  end
  self.onStartClientClick = function()
    self._isClient = not self._isClient
    if (self._isClient) then
      forms.setproperty(self._btnClientConnect, "Text", "Stop Connect")
      if clientConnector == nil then
        print("setup client connector")
        local client_udp = require("client_udp")
        clientConnector = client_udp.ClientSpawn
        cSocket = client_udp.clientSocket
        local bn = "localhost"
        local bp = forms.getproperty(self._txtUdpPort, "Text")
        local pn = forms.getproperty(self._txtConnect, "Text")
        local pp = forms.getproperty(self._txtConnectPort, "Text")
        local usr = forms.getproperty(self._txtUsername, "Text")
        clientConnector:setBindname(bn)
        clientConnector:setBindport(bp)
        clientConnector:setPeername(pn)
        clientConnector:setPeerport(pp)
        clientConnector:initSocket()
        clientConnector:setUsername(usr)
        clientConnector:testRun(inputTbl)
        self:setReadOnly()
        clientConnector:setForm(self)
        clientConnector:setInputQueue(inputTbl)
        clientConnector:startTimer()
      end
    else
      forms.setproperty(self._btnClientConnect, "Text", "Client Client")
    end
  end
  self.onSendMsgClick = function()
    local msg = forms.getproperty(self._txtChatMsg, "Text")
    return self:sendMsg(msg)
  end
  self._frmConnect = forms.newform(unpackArrValues({
    ({
      w = 320
    }),
    ({
      h = 420
    }),
    ({
      title = "Chat Box"
    }),
    ({
      fnClose = self.onClose
    })
  }))
  self._lblConnect = forms.label(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = "Connect to:"
    }),
    ({
      x = 10
    }),
    ({
      y = 10
    }),
    ({
      w = 140
    }),
    ({
      h = 30
    }),
    ({
      fw = true
    })
  }))
  self._txtConnect = forms.textbox(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = "localhost"
    }),
    ({
      w = 140
    }),
    ({
      h = 30
    }),
    ({
      bt = nil
    }),
    ({
      x = 150
    }),
    ({
      y = 10
    }),
    ({
      mlt = false
    }),
    ({
      fw = true
    }),
    ({
      scroll = "NONE"
    })
  }))
  self._lblConnectPort = forms.label(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = "Connect to UDP:"
    }),
    ({
      x = 10
    }),
    ({
      y = 40
    }),
    ({
      w = 140
    }),
    ({
      h = 30
    }),
    ({
      fw = true
    })
  }))
  self._txtConnectPort = forms.textbox(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = "51425"
    }),
    ({
      w = 140
    }),
    ({
      h = 30
    }),
    ({
      bt = nil
    }),
    ({
      x = 150
    }),
    ({
      y = 40
    }),
    ({
      mlt = false
    }),
    ({
      fw = true
    }),
    ({
      scroll = "NONE"
    })
  }))
  self._lblUdpPort = forms.label(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = "UDP Port:"
    }),
    ({
      x = 10
    }),
    ({
      y = 70
    }),
    ({
      w = 140
    }),
    ({
      h = 30
    }),
    ({
      fw = true
    })
  }))
  self._txtUdpPort = forms.textbox(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = "51424"
    }),
    ({
      w = 140
    }),
    ({
      h = 30
    }),
    ({
      bt = nil
    }),
    ({
      x = 150
    }),
    ({
      y = 70
    }),
    ({
      mlt = false
    }),
    ({
      fw = true
    }),
    ({
      scroll = "NONE"
    })
  }))
  self._lblUsername = forms.label(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = "Username:"
    }),
    ({
      x = 10
    }),
    ({
      y = 100
    }),
    ({
      w = 140
    }),
    ({
      h = 30
    }),
    ({
      fw = true
    })
  }))
  self._txtUsername = forms.textbox(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = "MyUsername"
    }),
    ({
      w = 140
    }),
    ({
      h = 30
    }),
    ({
      bt = nil
    }),
    ({
      x = 150
    }),
    ({
      y = 100
    }),
    ({
      mlt = false
    }),
    ({
      fw = true
    }),
    ({
      scroll = "NONE"
    })
  }))
  self._btnInvertPort = forms.button(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = "Invert Port"
    }),
    ({
      fnClick = self.onInvertPortClick
    }),
    ({
      x = 10
    }),
    ({
      y = 130
    }),
    ({
      w = 140
    }),
    ({
      h = 30
    })
  }))
  self._btnClientConnect = forms.button(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = "Client Connect"
    }),
    ({
      fnClick = self.onStartClientClick
    }),
    ({
      x = 150
    }),
    ({
      y = 130
    }),
    ({
      w = 140
    }),
    ({
      h = 30
    })
  }))
  self._lblStatus = forms.label(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = "Status:"
    }),
    ({
      x = 10
    }),
    ({
      y = 170
    }),
    ({
      w = 140
    }),
    ({
      h = 30
    }),
    ({
      fw = true
    })
  }))
  self._txtStatus = forms.textbox(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = "Unknown"
    }),
    ({
      w = 140
    }),
    ({
      h = 30
    }),
    ({
      bt = nil
    }),
    ({
      x = 150
    }),
    ({
      y = 170
    }),
    ({
      mlt = false
    }),
    ({
      fw = true
    }),
    ({
      scroll = "NONE"
    })
  }))
  forms.setproperty(self._txtStatus, "ReadOnly", true)
  self._txtChatBox = forms.textbox(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = ""
    }),
    ({
      w = 280
    }),
    ({
      h = 100
    }),
    ({
      bt = nil
    }),
    ({
      x = 10
    }),
    ({
      y = 200
    }),
    ({
      mlt = true
    }),
    ({
      fw = true
    }),
    ({
      scroll = "VERTICAL"
    })
  }))
  forms.setproperty(self._txtChatBox, "ReadOnly", true)
  self._lblChatMsg = forms.label(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = "Chat:"
    }),
    ({
      x = 10
    }),
    ({
      y = 310
    }),
    ({
      w = 50
    }),
    ({
      h = 30
    }),
    ({
      fw = true
    })
  }))
  self._txtChatMsg = forms.textbox(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = ""
    }),
    ({
      w = 230
    }),
    ({
      h = 30
    }),
    ({
      bt = nil
    }),
    ({
      x = 60
    }),
    ({
      y = 310
    }),
    ({
      mlt = false
    }),
    ({
      fw = true
    }),
    ({
      scroll = "NONE"
    })
  }))
  forms.setproperty(self._txtChatMsg, "ReadOnly", true)
  self._btnSendMsg = forms.button(unpackArrValues({
    ({
      frm = self._frmConnect
    }),
    ({
      cap = "Send Msg"
    }),
    ({
      fnClick = self.onSendMsgClick
    }),
    ({
      x = 150
    }),
    ({
      y = 340
    }),
    ({
      w = 140
    }),
    ({
      h = 30
    })
  }))
  forms.setproperty(self._btnSendMsg, "Enabled", false)
  FormConnect = _class_0
end
say = function(msg)
  return FormConnect:sendMsg(msg)
end
return {
  FormConnect = FormConnect,
  say = say
}
