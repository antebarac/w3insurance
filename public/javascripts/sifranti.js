function updateCombo(combo, id, label)
{
  optionSelector = combo + " option[value=" + id + "]";
  if($(optionSelector).size() == 0)
  {
    $(combo).append("<option value='" + id + "'>" + label + "</option>");
  }
  else
  {
    $(optionSelector).html(label);
  }
}

function deleteFromCombo(combo, id)
{
  $(combo + " option[value=" + id + "]").remove();
}


function sifrant_initButtons()
{
  $("button, input:submit, a.button").each(function(index, element) {
    $(element).button();
    var primaryIcon = $(element).attr("primary-icon");
    var secondaryIcon = $(element).attr("secondary-icon");
    var iconsValue = { primary: '', secondary: '' }
    if(primaryIcon != null) iconsValue.primary = 'ui-icon-' + primaryIcon;
    if(secondaryIcon != null) iconsValue.secondary = 'ui-icon-' + secondaryIcon;
    if(iconsValue != "") $(element).button('option', 'icons', iconsValue);
  });
}

function qsParam( name )
{
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( window.location.href );
  if( results == null )
    return "";
  else
    return results[1];
}

function sifrant_obrisi(id, msg)
{
  var s = this;
  sabreConfirm("Brisanje", msg, function() {
    $.post('/' + s.mnozina + '/' + id, '_method=DELETE', function(data) {
      target = $(s.table).attr('target');
      $("span#view-" + s.mnozina).load(s.reloadUrl(), function(){
        $(s.table).attr('target', target);
        s.podesiIkoneZaGrid();
        deleteFromCombo(target, id);
      });
    });
  });
}

function sifrant_search()
{
  var s = this;
  var onTdClick = $(s.table).data("onTdClick");
  query = $("input#" + s.mnozina + "-search-query").attr('value');
  target = $(s.table).attr('target');
  $("span#view-" + s.mnozina).load(encodeURI(s.searchUrl() + "&q=" + query), function(){
    $(s.table).attr('target', target);
    s.podesiIkoneZaGrid();
    if(onTdClick != null) $(s.table).find("td:not(.notClickable)").click(onTdClick);
  });
}

function sifrant_novo()
{
  var s = this;
  var span = $("<span id='" + s.jednina + "-dialog' style='overflow-y:auto'></span>");
  span.load('/' + s.mnozina + '/new?ajax=1', function () {
    span.dialog({
      title: 'Dodaj',
      resizable: true,
      width: s.dialogWidth,
      modal: true,
      buttons: {
        'Spremi' : function() { s.spremi($(this)); },
        'Odustani' :  function() { $(this).dialog('close'); } 
        },
      open: function() {
        var initf = s.mnozina + "_sifrant_initialize()";
        try { eval(initf); } catch(e) {}
        $(this).find("input[type!=hidden],select").first().focus();
        $(this).keydown(function(e) {
          if(e.keyCode == 13) {
            e.preventDefault();
            s.spremi($(this));
          }
        });
      },
      close: function(ev, ui) { $('span#' + s.jednina + '-dialog').remove(); }
    });
  });
}

function sifrant_podesiIkoneZaGrid()
{
  var s = this;
  $(function () {
    $(".notClickable a").hide();
    $(s.table + " tr").hover(function () {
      $(this).find(".notClickable a").show();
    }, function() {
      $(this).find(".notClickable a").hide(); 
    });
  });
}

function sifrant_izmijeni(id)
{
  var s = this;
  span = $("<span id='" + s.jednina + "-dialog'></span>");
  span.load('/' + s.mnozina + '/' + id + '/edit?ajax=1', function () {
    span.dialog({
      title: 'Izmijeni',
      resizable: true,
      width: s.dialogWidth,
      modal: true,
      buttons: {
        'Spremi' : function() { s.spremi($(this)); },
        'Odustani' : function() { $(this).dialog('close'); }
      },   
      open: function() {
        $(this).find("input[type!=hidden],select").first().focus();
        $(this).keydown(function(e) {
          if(e.keyCode == 13) {
            e.preventDefault();
            s.spremi($(this));
          }
        });
      },
      close: function(ev, ui) { $('span#' + s.jednina + '-dialog').remove(); }
    });
  });
}

function sifrant_spremi(source)
{
  toSend = source.find('form').serialize();
  url = source.find('form').attr('action');
  var s = this;
  $.post(url, toSend, function(data) {
    var ret = JSON.parse(data);
    $("span#error-messages").remove();
    $(".errorField").removeClass("errorField");
    if(ret.data == null)
    {
      $("span#" + s.jednina + "-dialog").prepend(unescape("<span id='error-messages'>" + ret.html_error + "</span>"));
      for(i=0; i<ret.errors.length; i++)
      {
        $("#" + s.jednina + "_" + ret.errors[i][0]).addClass("errorField");
      }
    }
    else
    {
      $(function() {
            target = $(s.table).attr('target');
            var naziv = ret.data[s.jednina].naziv;
            if(naziv == null) naziv = ret.data[s.jednina].opis;
            if(naziv == null) naziv = ret.data[s.jednina].oznaka;
            if(naziv == null) naziv = ret.data[s.jednina].ime + ' ' + ret.data[s.jednina].prezime;
            updateCombo(target, ret.data[s.jednina].id, naziv);
            $("span#" + s.jednina + "-dialog").dialog('close');
            $("span#view-" + s.mnozina).load(s.reloadUrl(), function() {
              $("div#notice").remove();
              $("div#info-popup").append("<div class='notice ui-corner-all' id='notice'>" + ret.flash + "</div>");
              $(s.table).attr('target', target);
              s.podesiIkoneZaGrid();
            });
      });
      setTimeout(function() { $("div#notice").fadeOut('slow'); }, 3000);
     }
  }, "application/x-json");
}

function sifrant_init(isPopup)
{
  var s = this;
  this.isPopup = isPopup;
  $(function() {
    sifrant_initButtons();
    if(s.dialogsEnabled)
    {
      $(s.table + ">tbody>tr>td:not(.notClickable)").click(function () {
        target = $(this).parent().parent().parent().attr("target");
        if (target == null)
        {
          s.izmijeni($(this).parent().attr("id"));
        }
        else
        {
          var value = $(this).parent().attr("id");
          $(target).attr("value", value);
          $(target).trigger('change', value);
          $("div#" + s.mnozina + "-dialog").dialog('close');
        }
      });
    }
    s.podesiIkoneZaGrid();
    $("input#" + s.mnozina + "-search-query").keydown(function(e) {
      if(e.keyCode == 13 && !$("input#" + s.mnozina + "-search-query").hasClass('message')) s.search();
    });
    $("span#view-" + s.mnozina + " .pagination a").click(function(event) {
      event.preventDefault();
      var pageUrl = $(this).attr("href");
      if(pageUrl.indexOf("ajax=1") == -1) pageUrl += "&ajax=1";
      if(pageUrl.search("q=$") != -1 || pageUrl.search("q=&") != -1) pageUrl = pageUrl.replace("/search", "");
      s.reload(pageUrl);
    });
    $("input#" + s.mnozina + "-search-query").focus();
  });
}

function sifrant_getReloadUrl(action)
{
  url = "/" + this.mnozina;
  if(action != null && action != "") url += "/" + action;
  url += "?ajax=1";
  if(qsParam("popup") == "1" || this.isPopup) url += "&popup=1";
  return url;
}

function sifrant_reload(url)
{
  var s = this;
  target = $(s.table).attr('target');
  $("span#view-" + s.mnozina).load(url, function(){
    $(s.table).attr('target', target);
    s.podesiIkoneZaGrid();
  });
}

function sifrant_reloadUrl()
{
  return this.getReloadUrl();
}

function sifrant_searchUrl()
{
  return this.getReloadUrl('search');
}

function sifrant_setDialogWidth(width)
{
  this.dialogWidth = width;
}

function sifrant_disableDialogs()
{
  this.dialogsEnabled = false;
}

function sifrant(mnozina, jednina, table)
{
  this.setDialogWidth = sifrant_setDialogWidth;
  this.mnozina = mnozina;
  this.jednina = jednina;
  this.table = table;
  this.isPopup = false;
  this.dialogsEnabled = true;

  this.getReloadUrl = sifrant_getReloadUrl;
  this.init = sifrant_init;
  this.izmijeni = sifrant_izmijeni;
  this.spremi = sifrant_spremi;
  this.obrisi = sifrant_obrisi;
  this.novo = sifrant_novo;
  this.podesiIkoneZaGrid = sifrant_podesiIkoneZaGrid;
  this.search = sifrant_search;
  this.reload = sifrant_reload;
  this.disableDialogs = sifrant_disableDialogs;

  this.reloadUrl = sifrant_reloadUrl;
  this.searchUrl = sifrant_searchUrl;
  
  this.dialogWidth = 400;

}





