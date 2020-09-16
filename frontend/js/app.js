$(document).ready(function(){
  $('.ui.dropdown').dropdown();
});

let id_token
let access_token
var endpoint = "https://xeazv7wi37.execute-api.us-east-1.amazonaws.com/device/shadow?thing_name=ee9b057feee9e9086d0e5e046b1a831b715743ec1b6766797fb38c6d5f43a62d"

function hideLoginButton(){
  document.getElementsByClassName("ui red button")[0].style.visibility = "hidden"; 
}

function showLogoutMessage(){
  document.getElementsByClassName("ui blue button")[0].style.visibility = "shown"
}

window.onload = async () => {
  const query = window.location.href;
  if (query.includes("id_token=") && query.includes("access_token=")) {
    hideLoginButton()
    id_token = query.match("(?<=id_token=)(.*)(?=&access_token)")[0]
    access_token = query.match("(?<=access_token=)(.*)(?=&expires_in)")[0]
    window.history.replaceState({}, document.title, "/");
    showDeviceAlarmState()
  }
};

async function showDeviceAlarmState() {
  var myHeaders = new Headers();
  myHeaders.append("Authorization", "Bearer " + id_token);
  
  var requestOptions = {
    method: 'GET',
    headers: myHeaders,
    redirect: 'follow'
  };
  
  fetch(
    "https://xeazv7wi37.execute-api.us-east-1.amazonaws.com/device/shadow?thing_name=ee9b057feee9e9086d0e5e046b1a831b715743ec1b6766797fb38c6d5f43a62d", 
    requestOptions
  )
    .then(response => response.json())
    .then(result => document.getElementById('alert_time').innerHTML = new Date(Number(result['state']['reported']['last_alarm'])*1000))
    .catch(error => console.log('error', error));
  document.getElementById('hidden_header').style = "";
}

