$(document).ready(function(){
  $('.ui.dropdown').dropdown();
});

var base_login_url = "https://service-user-pool-domain-dev-rainbow-unicorn-fppzs.auth.us-east-1.amazoncognito.com/"
var login_details_client_id = "login?client_id=40t99uorpg0n4jp3f22bsb9usf"
var login_details_response_type = "&response_type=token&scope=aws.cognito.signin.user.admin+email+openid+phone+profile"
var redirect_url = "&redirect_uri=http://localhost:8000"
var login_url = base_login_url + login_details_client_id + login_details_response_type + redirect_url
var get_votes_endpoint = "https://EXAMPLE_REPLACE_ME.execute-api.us-east-1.amazonaws.com/dev/votes"

function hideLoginButton(){
  document.getElementsByClassName("ui red button")[0].style.visibility = "hidden"; 
}


window.onload = async () => {
  const query = window.location;
  if (query.includes("id_token=") && query.includes("access_token=")) {
    hideLoginButton()
    window.history.replaceState({}, document.title, "/");
    console.log(query)
  }
};



async function process_login() {
  // Get the vote counts
  const response = await fetch(get_votes_endpoint);
  const songs = await response.json();
  // Iterate over all three songs and update the divs
  var i;
  for (i = 0; i < songs.length; i++){
    var featured_songs = ["coderitis", "stateless", "dynamo"];
    var song = songs[i]
    if (featured_songs.includes(song["songName"])){
      console.log(song)
      setVotes(song["songName"], song["votes"])
    }
  }
}

async function voteForSong(songName) {
  const response = await fetch(vote_endpoint, {
    method: "POST",
    mode: 'cors',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({"songName": songName})
  })
  const result_json = await response.json()
  setVotes(songName, result_json["votes"])
}

function recordVote() {
  if (document.getElementsByClassName("item active selected")[0]) {
    var selectedSong = document.getElementsByClassName("item active selected")[0].getAttribute('data-value')
    if (selectedSong) {
      voteForSong(selectedSong)
      console.log("voted for " + selectedSong)
    }
  }
}