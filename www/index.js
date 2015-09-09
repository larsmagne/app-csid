phoneGap = true;

$.support.cors = true;

function splash() {
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
    window.requestFileSystem(
      LocalFileSystem.PERSISTENT, 0,
      function(fileSystem) {
        fileSystem.root.getFile(
	  "cache.html", null,
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
  } else {
    $.ajax({
      url: "http://csid.no/index.html",
      dataType: "text",
      success: function(data) {
	var div = document.createElement("div");
	div.innerHTML = data;
	$(div).find("script").remove();
	$(div).find("head").remove();
	document.body.innerHTML = "";
	document.body.appendChild(div);
	addNavigation();
      },
      error: function(error) {
	console.log(error);
      }
    });
  }
}

function displayCache(text) {
  alert("success");
  var div = document.createElement("div");
  div.innerHTML = text;
  document.body.innerHTML = "";
  document.body.appendChild(div);
  addNavigation();
  $.colorbox({html: "<div class='venue-top'>Device offline; showing cached data</div>",
	      width: $(window).width() + "px",
	      close: "Close",
	      transition: "none",
	      className: "event-lightbox"});
}

function displayCacheFailure() {
  alert("failure");
  $.colorbox({html: "<div class='venue-top'>Device offline and no cache available</div><a href='#' id='csid-close'>Close</a>",
	      width: $(window).width() + "px",
	      closeButton: false,
	      transition: "none",
	      className: "event-lightbox"});
  $("#csid-close").bind("click", function() {
    navigator.app.exitApp();
    return false;
  });
}

splash();
