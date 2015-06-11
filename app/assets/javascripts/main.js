var switch_flow = function(response_type) {
    var text = "None";
    switch (response_type) {
      case 'id_token':
      case 'id_token token':
        text = "Implicit";
        break;
      case 'code':
        text = "Authorization Code";
        break;
      case 'id_token code token':
      case 'id_token code':
      case 'code token':
        text = "Hybrid";
        break;
      default:
        text = "Invalid Selection"
        break;
    }
    return text;
};
var check_flow = function() {
    var response_type = $(".response_type:checked").map(function() {
      return this.value;
    }).get().join(' ');
    //console.log("response: '" + response_type + "'");
    var flow = switch_flow(response_type);
    $("#flow_text").text(flow);
};
var cleanArray = function(actual){
  var newArray = new Array();
  for(var i = 0; i<actual.length; i++){
    if (actual[i]){
      newArray.push(actual[i]);
    }
  }
  return newArray;
}

/* given id_token, code, and token, return a parameter-like string
 * for use with the diagram ajax call
 */
var tokens2Flow = function(options) {
  var str = cleanArray([ 
    options['id_token'] ? "id_token" : undefined,
    options['code'] ? "code" : undefined,
    options['token'] ? "token" : undefined,
  ]).join(' ');
  switch( switch_flow( str ) ) {
    case "Implicit":
      return 'implicit';
      break;
    case "Authorization Code":
      return "authorization_code";
      break;
    case "Hybrid":
      return "hybrid";
      break;
  }
}

var getExpiresIn = function() {
  var expires_in = window.location.href.match('expires_in=([^&]*)');
  if ( expires_in )
    return expires_in[1];
  return null;
}

var load_buttons = function(endpoint, selector) {
  $.get(endpoint, function(data) {
    for ( var i = 0 ; i < data.length ; i++ )
    {
      var provider = data[i]; 
      providers[ provider["name"] ] = {
        'client_id': provider["client_id"],
        'redirect_uri': provider["redirect_uri"],
        // seems like most discovery endpoints don't do CORS.  :(
        //'provider': provider["provider"]
        'provider_info': {
          'issuer': provider["issuer"],
          'authorization_endpoint': provider["authorization_endpoint"],
          'jwks_uri': provider["jwks_uri"],
          'userinfo_endpoint': provider["userinfo_endpoint"]
        },
        // internal database ID for this custom defined provider
        'provider_id': provider["id"]  
      };
      var $button = $("<button onClick=\"login('" + provider["name"] + "')\">Sign in with " + provider["name"] + "</button>");
      $button.addClass('btn btn-primary');
      $button.appendTo( $(selector) );
    }
  });
}
$(document).ready(function() {
  check_flow();
  /* Monitor for check changes and update the Flow text
   * to reflect the OAuth2 flow
   */
  $(".response_type").change(function() {
    check_flow();
  });  
});
