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
    console.log(query)
    showDeviceAlarmState()
  }
};

async function showDeviceAlarmState() {
  const response = await fetch(endpoint, {
      method: 'GET',
      mode: 'cors',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + id_token
      }
  })
  const result_json = await response.json()
  console.log(result_json)
  document.getElementById('alert_time')[0].innerHTML = result_json;
}
