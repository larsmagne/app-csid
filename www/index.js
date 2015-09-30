phoneGap = true;
var loadTime = Date.now();

$.support.cors = true;

function splash() {
  document.addEventListener("backbutton", function() {
    if ($("#csid-close").length)
      $.colorbox.close();
    else
      navigator.app.exitApp();
    return false;
  }, false);

  document.addEventListener("resume", function() {
    if (Date.now() - loadTime > 1000 * 60 * 60 * 8)
      loadData();
  }, false);

  var img = new Image();
  img.onload = function() {
    var width = window.innerWidth;
    var height = window.innerHeight;
    var x = img.width;
    var y = img.height;
    var scale = width / x;
    var yClip = 0;
    var xClip = 0;
    if (y * scale > height) {
      var newY = Math.round(y * scale);
      img.style.width = width + "px";
      img.style.height = newY + "px";
      yClip = Math.round((newY - height) / 2);
    } else {
      scale = height / y;
      var newX = Math.round(x * scale);
      img.style.width = newX + "px";
      img.style.height = height + "px";
      xClip = Math.round((newX - width) / 2);
    }
    img.style.top = "-" + yClip + "px";
    img.style.left = "-" + xClip + "px";
    img.style.position = "absolute";
    img.style.zIndex = -1;
    document.body.appendChild(img);
    loadData();
  };
  img.src = "splash/splash" + Math.floor((Math.random() * 4 + 1)) + ".jpg";
}

var base = "http://csid.no";

function loadData() {
  if (navigator.network.connection.type === Connection.UNKNOWN ||
      navigator.network.connection.type === Connection.NONE) {
    loadCache();
  } else {
    $.ajax({
      url: "http://csid.no/index.html?ts=" + Date.now(),
      dataType: "text",
      success: function(data) {
	var div = document.createElement("div");
	div.innerHTML = data;
	$(div).find("script").remove();
	$(div).find("head").remove();
	    document.body.innerHTML = "";
	    document.body.appendChild(div);
	    addNavigation();
	    saveCache(data);
	    loadTime = Date.now();
      },
      error: function(error) {
	loadCache();
      }
    });
  }
}

function loadCache() {
  window.requestFileSystem(
    LocalFileSystem.PERSISTENT, 0,
    function(fileSystem) {
      fileSystem.root.getFile(
	"csid-cache.html", null,
	function(fileEntry) {
	  fileEntry.file(
	    function(file) {
	      var reader = new FileReader();
	      reader.onloadend = function(evt) {
		displayCache(evt.target.result);
	      };
	      reader.readAsText(file);
	    },		
	    displayCacheFailure);
	},
	displayCacheFailure);
    },
    displayCacheFailure
  );
}

function displayCache(text) {
  var div = document.createElement("div");
  div.innerHTML = text;
  $(div).find("script").remove();
  $(div).find("head").remove();
  document.body.innerHTML = "";
  document.body.appendChild(div);
  addNavigation();
  $.colorbox({html: "<div class='venue-top'>Unable to fetch new data; showing cached data</div>",
	      width: $(window).width() + "px",
	      close: "Close",
	      transition: "none",
	      className: "event-lightbox"});
}

function displayCacheFailure() {
  $.colorbox({html: "<div class='venue-top'>Couldn't fetch new data and no cache available</div><a href='#' id='csid-close'>Close</a>",
	      width: $(window).width() + "px",
	      closeButton: false,
	      transition: "none",
	      className: "event-lightbox"});
  $("#csid-close").bind("click", function() {
    navigator.app.exitApp();
    return false;
  });
}

function saveCache(data) {
  window.requestFileSystem(
    LocalFileSystem.PERSISTENT, 0,
    function(fileSystem) {
      fileSystem.root.getFile(
	"csid-cache.html",
	{create: true,
	 exclusive: false},
	function(fileEntry) {
          fileEntry.createWriter(
	    function(writer) {
              writer.onwriteend = function(evt) {
              };
              writer.write(data);
	    },
	    fail);
	},
	fail);
    },
    fail);
}

function waitForWebfonts(fonts, callback) {
  var loadedFonts = 0;
  for(var i = 0, l = fonts.length; i < l; ++i) {
    (function(font) {
      var node = document.createElement('span');
      // Characters that vary significantly among different fonts
      node.innerHTML = 'giItT1WQy@!-/#';
      // Visible - so we can measure it - but not on the screen
      node.style.position      = 'absolute';
      node.style.left          = '-10000px';
      node.style.top           = '-10000px';
      // Large font size makes even subtle changes obvious
      node.style.fontSize      = '300px';
      // Reset any font properties
      node.style.fontFamily    = 'sans-serif';
      node.style.fontVariant   = 'normal';
      node.style.fontStyle     = 'normal';
      node.style.fontWeight    = "bold";
      node.style.letterSpacing = '0';
      document.body.appendChild(node);

      // Remember width with no applied web font
      var width = node.offsetWidth;

      node.style.fontFamily = font;

      var interval;
      var checkFont = function() {
        // Compare current width with original width
        if(node && node.offsetWidth != width) {
          ++loadedFonts;
          node.parentNode.removeChild(node);
          node = null;
        }

        // If all fonts have been loaded
        if (loadedFonts >= fonts.length) {
          if (interval) {
            clearInterval(interval);
          }
          if (loadedFonts == fonts.length) {
            callback();
            return true;
          }
        }
	return false;
      };

      if(!checkFont()) {
        interval = setInterval(checkFont, 50);
      }
    })(fonts[i]);
  }
}

function fail() {
  alert("Failed saving the cache");
}

document.addEventListener("deviceready", splash, false);
