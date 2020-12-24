function addStyle(styleString) {
  const style = document.createElement('style');
  style.textContent = styleString;
  document.head.append(style);
}

addStyle(`
@keyframes raptorGO {
  25%  {
    transform: translateY(0);
  }
  35%  {
    right: 0;
    transform: translateY(25%);
  }
  75%  {
    opacity: 1;
  }
  100% {
    opacity: 0;
    right: 100%;
    transform: translateY(25%);
  }
}

.raptor {
  display: none;
  bottom: 0;
  position: fixed;
  transform: translateY(100%);
  right: 0;
}

.raptor-go {
  animation: raptorGO 2500ms;
}
`);

var Raptorize = (function(extended) {
  'use strict';

  var body, defaults, options,
      audioTemplate, sourceAudioTemplate, imageTemplate,
      audio, image;

  body = document.body;
  options = {};

  //--- OPTIONS ---//
  defaults = {
    audioPath: ['assets/sounds/raptor.mp3', 'assets/sounds/raptor.ogg'],
    imagePath: 'assets/images/raptor.png',

    className: 'raptor',
    animationTime: 2000
  };

  extend(options, defaults, extended);

  //--- SETUP ---//
  audioTemplate = document.createElement('audio');
  audioTemplate.className = options.className + '-source';

  for (var source in options.audioPath) {
    sourceAudioTemplate = document.createElement('source');
    sourceAudioTemplate.src = options.audioPath[source];
    audioTemplate.appendChild(sourceAudioTemplate);
  }

  imageTemplate = document.createElement('img');
  imageTemplate.className = options.className;
  imageTemplate.src = options.imagePath;

  audio = body.appendChild(audioTemplate);
  image = body.appendChild(imageTemplate);

  image.style.display = 'none';

  //--- THE HILARITY ---//
  function go() {
    // setTimeout(function () {
    //   audio.play();
    // }, (options.animationTime / 3));
    audio.play();

    image.style.display = 'block';
    image.classList.add(options.className + '-go');

    setTimeout(function () {
      image.classList.remove(options.className + '-go');
    }, options.animationTime);
  }

  //--- EXTEND (COMMON) ---//
  // Use Object.assign() for EcmaScript 6.
  function extend(out) {
    out = out || {};

    for (var i = 1; i < arguments.length; i++) {
      if (!arguments[i]) { continue; }
      for (var key in arguments[i]) {
        if (arguments[i].hasOwnProperty(key)) { out[key] = arguments[i][key]; }
      }
    }

    return out;
  }

  return { go: go }
});



//--- USAGE ---//
var myRaptor = Raptorize({
  audioPath: ['https://zurb.com/playground/uploads/upload/upload/230/raptor-sound.mp3',
              'https://zurb.com/playground/uploads/upload/upload/231/raptor-sound.ogg'],
  imagePath: 'https://zurb.com/playground/uploads/upload/upload/224/raptor.png',
});

setTimeout(myRaptor.go, 3000);