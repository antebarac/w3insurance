// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var onClickPartner = function (element) {
  return true;
};

function enterIcon()
{
   $(this).addClass("ui-state-hover").css('cursor', 'pointer');
}
function exitIcon()
{
  $(this).removeClass("ui-state-hover").css('cursor', 'default');
}

function sabreAlert(title, message)
{
  $("<div title='" + title + "'>" + message + "</div>").dialog({
    bgiframe: true,
    modal: true,
    buttons: {
        Ok: function() {
         $(this).dialog('close');
       }
      }
   });
}

function sabreConfirm(title, message, onConfirm)
{

  $("<div title='" + title + "'>" + message + "</div>").dialog({
    bgiframe: true,
    resizable: false,
    height:140,
    modal: true,
    buttons: {
      Ok: function() {
        onConfirm();
        $(this).dialog('close');
      },
      Cancel: function() {
        $(this).dialog('close');
      }
    }
  });
}


function showDialog(naziv, ddl_naziv, onClickItem)
{
  $("<div id='" + naziv + "-dialog'></div>").load('/' + naziv + '?ajax=1&popup=1', null, function(r, s, h) {
      $(function() {
        $("button").button();
      });
      $("div#" + naziv + "-dialog table").attr("target", "form #" + ddl_naziv);
      if(onClickItem != null)
      {
        $("div#" + naziv + "-dialog table td:not(.notClickable)").click(onClickItem);
        $("div#" + naziv + "-dialog table").data("onTdClick", onClickItem);
      }
  }).dialog({
    resizable: false,
    modal: true,
    title: 'Odabir',
    width: 750,
    height: 550,
    close: function() { $("div#" + naziv + "-dialog").remove(); }
  });
}

function showOsiguranja(osiguranje, grupa, title)
{
  uri = 'nova_stavka?osiguranje=' + osiguranje + '&grupa=' + grupa + '&ajax=1';
  $("<div id='dodaj-osiguranje-dialog' title='" + title + "'></div>").load(uri).dialog({
    resizable: false,
    width: 820,
    height: 580,
    modal: true,
    buttons: {
      'Dodaj' : function() {  dodajStavku(osiguranje, grupa);  },
      'Odustani' : function() { $(this).dialog('close'); }
    },
    close: function() { $("div#dodaj-osiguranje-dialog").remove(); }
  });
  $(function(){ 
    $("div#dodaj-osiguranje-dialog ~ .ui-dialog-buttonpane")
      .prepend("<span class='iznos-premije'>Iznos: <span id='stavka_iznos_premije' class='ui-widget-header ui-corner-all'>0,00 kn</span></span>"); 
    $('#dodaj-osiguranje-dialog').keyup(function(e) {
      if (e.keyCode == 13) {
        dodajStavku(osiguranje, grupa);
      }
    });
  });
}


function dodajStavku(osiguranje, grupa) 
{
  var input = $("<input type='hidden' name='osiguranje[postavke][]' />");
  input.attr('value', JSON.stringify($("div#dodaj-osiguranje-dialog form").serializeArray()));
  $("#osiguranja").append(input);
  
  $.post("/police/validiraj_stavku?osiguranje=" + osiguranje + "&grupa=" + grupa  + "&ajax=1", 
    $("div#dodaj-osiguranje-dialog form").serialize(), function(data, textStatus) {
     $("div#dodaj-osiguranje-dialog form .invalid").removeClass("invalid");
     var data = JSON.parse(data);
     var messages = data["messages"];
     if (messages.length > 0)
     {
       $("#stavka_" + messages[0][0]).focus().select();
       $.each(messages, function(i,token) {
        $("#stavka_" + token[0]).addClass("invalid");
       });
     }
     else 
     {
       $.post("/police/stavka_osiguranja?osiguranje=" + osiguranje + "&grupa=" + grupa + "&ajax=1", 
         $("div#dodaj-osiguranje-dialog form").serialize(), function(data, textStatus) {
         $("#stavke_osiguranja").append(data);
         $(function() {
            sum = 0.0;
            $("input[name='premija_stavke']").each(function(i, token) {
              sum += parseFloat($(token).attr("value"));
            });
            $("#stavke-suma").html(sum.toString().replace(".", ","));
            $(function() { $("#stavke-suma").formatCurrency({ region: defaultCurrencyRegion }).append(" kn"); });
          });
        });
        $("fieldset#stavke").show();
        $("div#dodaj-osiguranje-dialog").dialog('close');
     }
  });
}

function addIconClick(target, icon, onClick)
{
  target.append("<div class='ui-state-default ui-corner-all icon' onclick=\"" + onClick + "\">" +
      "<div class='icon-link ui-icon ui-icon-circle-close left'></div></div>");
}


function touchSearchBox(input)
{
  if($(input).hasClass('message'))
  {
    $(input).attr('value', '');
    $(input).removeClass('message');
  }
}
