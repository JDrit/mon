function stringGen(len) {
    var text = "";
    var charset = "abcdefghijklmnopqrstuvwxyz0123456789";
            
    for( var i=0; i < len; i++ ) {
        text += charset.charAt(Math.floor(Math.random() * charset.length));
    }
    return text;
}

$(document).on('page:update', function() {
    $("#generate_api_button").click(function() {
    $("#computer_api_key").val(stringGen(25));    
    });
});
