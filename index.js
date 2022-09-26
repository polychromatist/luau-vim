class Screenshot {
  static first;
  static imageClassName = "d-block w-100";

  constructor(caption, resource) {
    this.caption = caption;
    this.image = new Image();
    this.image.src = resource;
    this.image.className = Screenshot.imageClassName;
    this._placeholderImage = new Image();
    this._placeholderImage.src = "...";
    this._placeholderImage.alt = "...";
    this._placeholderImage.className = Screenshot.imageClassName;
    this._desc = {};
    this._callbacks = {
      onRender: []
    };
  }

  setFirst() {
    if (!this.element) {
      throw new Exception("no element is rendered")
    }

    this.element.className += " active";
    Screenshot.first = this;
  }

  resetFirst() {
    if (Screenshot.first != this)
      return

    this.element.className.replace(/ active/, "");
    Screenshot.first = null;
  }

  render() {
    if (this.element) this.element.remove();

    this.element = document.createElement('div');
    this.element.className = "carousel-item";
    if(this.image.complete)
      this.element.appendChild(this.image);
    else {
      this.element.appendChild(this._placeholderImage);
      this.image.onload = () => {
        console.log("hello there");
        this.element.removeChild(this._placeholderImage);
        this.element.addChild(this.image);
      };
    }
    this._dispatchCallbacks('onRender'); 
  }

  derender() {
    if (!this.element)
      return;
  }

  addListener(category, callback) {
    if (!this._callbacks.hasOwnProperty(category))
      throw new Exception(`unknown callback category "${category}"`);

    this._callbacks[category].push(callback);
  }

  removeListener(category, callback) {
    const _i = this._callbacks.indexOf(callback);
    if (_i > -1)
      this._callbacks.splice(_i, 1);
  }

  _dispatchCallbacks(category) {
    this._callbacks[category].forEach((callback) => callback());
  }

  addLink(url) {
    if (!this.element)
      throw new Exception("no element is rendered");


  }

  addDescEntry(name, data) {

  }
}

function process(data) {
  const screenshots = [];
  data.list.forEach(({source, font, resource, theme}) => {
    const s = new Screenshot(source.title, resource);
    s.render();
    if(source.hasOwnProperty("link")) s.addLink(source.link);
    if(source.hasOwnProperty("theme")) s.addDescEntry("Theme", source.theme);
    if(source.hasOwnProperty("font")) s.addDescEntry("Font", source.font);
    screenshots.push(s);
  });
  return {
    Screenshots: screenshots
  };
}
/*
var xhr = new XMLHttpRequest();
xhr.addEventListener("load", () => parse(this.response));
xhr.open("GET", "screenshots/list.json");
xhr.send(null);*/
var data = {
  "list": [
    {
      "source": {
        "title": "@NightrainsRbx/RobloxLsp",
        "link": "https://github.com/NightrainsRbx/RobloxLsp",
        "path": "server/def/3rd/roact.luau"
      },
      "font": "Fira Code",
      "resource": "robloxlsp_roactluau.png",
      "theme": "moonfly"
    },
    {
      "source": {
        "title": "@Anaminus/Bitbuf",
        "link": "https://github.com/Anaminus/roblox-library/tree/master/modules/Bitbuf",
        "path": "Bitbuf.lua"
      },
      "font": "Fira Code",
      "resource": "bitbuf_stringmtindex.png",
      "theme": "Gruvbox &background=dark"
    },
    {
      "source": {
        "title": "@evaera/matter",
        "link": "https://github.com/evaera/matter",
        "path": "lib/World.lua#query()"
      },
      "font": "6x13",
      "resource": "evaera_matter_world_query.png",
      "theme": "elflord"
    },
    {
      "source": {
        "title": "geoplane",
        "path": "Mesh3/Mesh3__type.lua"
      },
      "font": "6x13",
      "resource": "geoplane_mesh__type.png",
      "theme": "moonfly"
    },
    {
      "source": {
        "title": "@Novetus/Novetus-src",
        "link": "https://github.com/Novetus/Novetus-src",
        "path": "scripts/game/2012M/CSMPFunctions.lua"
      },
      "font": "6x13",
      "resource": "novetus_2012m_csmpfunctions.png",
      "theme": "moonfly"
    }
  ]
};

function main() {
  let page = 1;

  var screenshotCarousel = document.querySelector("#carouselScreenshots");
  var screenshotAnchor = screenshotCarousel.children[0];

  function addScreenshotToDOM(screenshot) {
    screenshotAnchor.appendChild(screenshot.element);
  }

  var myenv = process(data);

  myenv.Screenshots.forEach(screenshot => {
    if (screenshot.hasOwnProperty("element"))
      addScreenshotToDOM(screenshot);
    screenshot.addListener('onRender', addScreenshotToDOM);
  });

  Promise.all(myenv.Screenshots.map(screenshot => new Promise((res) => {
    if(screenshot.hasOwnProperty("element")) {
      addScreenshotToDOM(screenshot);
      res();
      return;
    }
    screenshot.addListener('onRender', () => {
      addScreenshotToDOM(screenshot);
      res();
    });
  }))).then(() => {
    console.log("hello there");
    new bootstrap.Carousel('#carouselScreenshots')
  });
}

if(document.readyState != "loading") {
  main();
} else {
  document.addEventListener("DOMContentLoaded", (event) => {
    main();
  })
}
