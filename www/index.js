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
    var currentPos = $(".front-logo").position().top;
    $(".front-logo").animate({
      top: "+=" + (height - currentPos - 80 - $(".front-logo").height()) + "px"
    });
    loadData();
  };
  img.src = "splash/splash" + Math.floor((Math.random() * 4 + 1)) + ".jpg";
}

var base = "http://csid.no";

function loadData() {
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

splash();
