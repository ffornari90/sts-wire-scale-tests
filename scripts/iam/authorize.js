var page = require('webpage').create();
var fs = require('fs');
var cookieJarFilePath = 'cookies.txt';
var clientId = '';
var redirectUris = '';
var args = require('system').args;
var iamServer = args[1];
var clientInfoFilePath = args[2];

page.viewportSize = {
  width: 1920,
  height: 1080
};

function log(msg) {
  console.log('LOG: ' + msg);
}

page.onError = function(msg, trace) {
  console.log('ERROR: ' + msg);
};

readCookiesFromFile = function() {
  cookieJar = [];
  if(fs.isFile(cookieJarFilePath)) {
    cookieJar = JSON.parse(fs.read(cookieJarFilePath));
  }
  for(var j in cookieJar) {
    phantom.addCookie({
      'name'     : cookieJar[j].name,
      'value'    : cookieJar[j].value,
      'domain'   : cookieJar[j].domain,
      'path'     : cookieJar[j].path,
      'httponly' : cookieJar[j].httponly,
      'secure'   : cookieJar[j].secure,
      'expires'  : cookieJar[j].expires
    });
  }
};

readCookiesFromFile();

readClientInfoFromFile = function() {
  clientInfo = [];
  if(fs.isFile(clientInfoFilePath)) {
    clientInfo = JSON.parse(fs.read(clientInfoFilePath));
  }
  clientId = clientInfo.client_id;
  redirectUris = clientInfo.redirect_uris;
}

readClientInfoFromFile();

page.open('https://' + iamServer + '/authorize?response_type=code&redirect_uri=' + redirectUris + '&client_id=' + clientId, function(status) {
  if (status !== 'success') {
    console.log('Failed to load the page');
    phantom.exit();
  }

  setTimeout(function() {
    page.evaluate(function() {
      var button = document.querySelector("#wrap > div > div > div.container-fluid.page-content > div:nth-child(1) > form > div > div.scopes-box > div:nth-child(18) > input.btn.btn-success.btn-large");
      if (button) {
        button.click();
        console.log('Button clicked successfully.');
      } else {
        console.log('Button not found.');
      }
    });
    setTimeout(function() {
      console.log(page.url);
      phantom.exit();
    }, 1000);
  }, 5000);
});
