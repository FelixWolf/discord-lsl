/**************** START DISCORD WEBHOOKS ****************/
// Utility functions
string object(list a){return llList2Json(JSON_OBJECT, a);}
string array(list a){return llList2Json(JSON_ARRAY, a);}

string objectKey(string src, list dir, string def){
    src = llJsonGetValue(src,dir);
    if(src == JSON_INVALID)
        return def;
    return src;
}

/**************** DOCUMENTATION ****************
//Webhooks
string WebhookCreate(string id, string token)
    Create a webhook.
    id should be the integer part of the webhook.
    token should be the long text part of the webhook.

key WebhookGetInfo(string data)
    Creates a request to get info on the webhook.

key WebhookDelete(string data)
    Deletes a webhook!

key WebhookMessageSend(string data)
    Send a webhook created with WebhookCreate.
    
key WebhookMessageEdit(string data)
    Deletes a message (Body not required, needs ["id", "token", "message"])

key WebhookMessageDelete(string data)
    Deletes a message (Body not required, needs ["id", "token", "message"])

string WebhookSetFields(string data, list props)
    INTERNAL: Set webhook "body" properties.

string WebhookSetMessageID(string data, string id)
    Set the message ID of a webhook (For editing or deleting)

string WebhookSetText(string data, string text)
    Set webhook body. Similar to setting an embed Description.

string WebhookSetUsername(string data, string text)
    Override username of webhook.

string WebhookSetAvatar(string data, key avatar)
    Override avatar of webhook. avatar is asset ID.

string WebhookSetEmbeds(string data, list embeds)
    Set webhook's embeds with a list of EmbedCreate elements.


//Embeds
string EmbedCreate(string timestamp)
    Create a rich embed.

string EmbedSetFields(string data, list props)
    INTERNAL: Used to set bulk properties.

string EmbedSetTitle(string data, string text)
    Set embed title.

string EmbedSetDescription(string data, string text)
    Set embed description.

string EmbedSetUrl(string data, string text)
    Set embed URL.

string EmbedSetColor(string data, vector col)
    Set embed color.
    Uses LSL color. <r, g, b>, 0.0 to 1.0.

string EmbedSetFooter(string data, string text, key icon)
    Set embed footer.
    Icon is optional and can be blank. Icon is a asset ID.

string EmbedSetImage(string data, key image)
    Set embed image to a texture ID.

string EmbedSetThumbnail(string data, key thumbnail)
    Set embed thumbnail to a texture ID.

string EmbedSetVideo(string data, string url, integer width, integer height)
    Set embed video.
    URL can be any video in format of webm, mp4, or mpeg.
    Width and Height must be specified.

string EmbedSetProvider(string data, string name, string url)
    Set embed provider.
    URL is optional and can be blank.

string EmbedSetAuthor(string data, string name, string url, key icon)
    Set embed author.
    Icon is optional and can be blank. Icon is a asset ID.

string EmbedAddField(string data, string name, string value, integer inline)
    Add a field to embed.
    If inline is TRUE, then field will appear on last line of previous field if previous field is also inline, else next field if next field is inline.
**************** END DOCUMENTATION ****************/
// Webhook
string WebhookCreate(string id, string token){
    return object([
        "id", id,
        "token", token,
        "message", FALSE, //Message ID for editing
        "body", "{}"
    ]);
}
key WebhookGetInfo(string data){
    return llHTTPRequest(
        "https://discordapp.com/api/webhooks/"
        +objectKey(data, ["id"], "")+"/"+objectKey(data, ["token"], ""),
        [
            HTTP_METHOD, "GET",
            HTTP_MIMETYPE, "application/json"
        ],
        ""
    );
}
key WebhookDelete(string data){
    return llHTTPRequest(
        "https://discordapp.com/api/webhooks/"
        +objectKey(data, ["id"], "")+"/"+objectKey(data, ["token"], ""),
        [
            HTTP_METHOD, "DELETE",
            HTTP_MIMETYPE, "application/json"
        ],
        ""
    );
}
key WebhookMessageSend(string data){
    return llHTTPRequest(
        "https://discordapp.com/api/webhooks/"
        +objectKey(data, ["id"], "")+"/"+objectKey(data, ["token"], ""),
        [
            HTTP_METHOD, "POST",
            HTTP_MIMETYPE, "application/json"
        ],
        objectKey(data, ["body"], "")
    );
}
key WebhookMessageEdit(string data){
    return llHTTPRequest(
        "https://discordapp.com/api/webhooks/"
        +objectKey(data, ["id"], "")+"/"+objectKey(data, ["token"], "")
        +"/messages/"+objectKey(data, ["message"], ""),
        [
            HTTP_METHOD, "PATCH",
            HTTP_MIMETYPE, "application/json"
        ],
        objectKey(data, ["body"], "")
    );
}
key WebhookMessageDelete(string data){
    return llHTTPRequest(
        "https://discordapp.com/api/webhooks/"
        +objectKey(data, ["id"], "")+"/"+objectKey(data, ["token"], "")
        +"/messages/"+objectKey(data, ["message"], ""),
        [
            HTTP_METHOD, "DELETE",
            HTTP_MIMETYPE, "application/json"
        ],
        ""
    );
}
string WebhookSetMessageID(string data, string value){
    return llJsonSetValue(data, ["message"], value);
}
string WebhookSetFields(string data, list props){
    integer i = 0;
    integer l = llGetListLength(props);
    for(;i<l;i+=2){
        data = llJsonSetValue(data, ["body", llList2String(props, i)], llList2String(props, i+1));
    }
    return data;
}
string WebhookSetText(string data, string text){return WebhookSetFields(data, ["content", text]);}
string WebhookSetUsername(string data, string text){return WebhookSetFields(data, ["username", text]);}
string WebhookSetAvatar(string data, key avatar){return WebhookSetFields(data, ["avatar_url", "http://texture-service.agni.lindenlab.com/"+(string)avatar+"/256x192/"]);}
string WebhookSetEmbeds(string data, list embeds){return WebhookSetFields(data, ["embeds", array(embeds)]);}

//Embeds
string EmbedCreate(string timestamp){
    list embed = [
        "type", "rich",
        "fields", "[]"
    ];
    if(timestamp == "now") timestamp == llGetTimestamp();
    if(timestamp != "") embed+=["timestamp", llGetTimestamp()];
    return object(embed);
}

string EmbedSetFields(string data, list props){
    integer i = 0;
    integer l = llGetListLength(props);
    for(;i<l;i+=2){
        data = llJsonSetValue(data, [llList2String(props, i)], llList2String(props, i+1));
    }
    return data;
}

string EmbedSetTitle(string data, string text){return EmbedSetFields(data, ["title", text]);}
string EmbedSetDescription(string data, string text){return EmbedSetFields(data, ["description", text]);}
string EmbedSetUrl(string data, string text){return EmbedSetFields(data, ["url", text]);}
string EmbedSetColor(string data, vector col){return EmbedSetFields(data, ["color", ((llRound(col.x*255)&0xFF)<<16) | ((llRound(col.y*255)&0xFF) << 8) | ((llRound(col.z*255)&0xFF))]);}
string EmbedSetFooter(string data, string text, key icon){
    list tmp = ["text", text];
    if(icon!="")tmp+=["icon", "http://texture-service.agni.lindenlab.com/"+(string)icon+"/256x192/"];
    return EmbedSetFields(data, ["footer", object(tmp)]);
}
string EmbedSetImage(string data, key image){
    return EmbedSetFields(data, ["image", object(["url", "http://texture-service.agni.lindenlab.com/"+(string)image+"/256x192/", "width", 256, "height", 192])]);
}
string EmbedSetThumbnail(string data, key thumbnail){
    return EmbedSetFields(data, ["thumbnail", object(["url", "http://texture-service.agni.lindenlab.com/"+(string)thumbnail+"/256x192/", "width", 256, "height", 192])]);
}
string EmbedSetVideo(string data, string url, integer width, integer height){
    return EmbedSetFields(data, ["video", object(["url", url, "width", width, "height", height]);
}
string EmbedSetProvider(string data, string name, string url){
    list tmp = ["name", name];
    if(url!="")tmp+=["url", url];
    return EmbedSetFields(data, ["provider", object(tmp)]);
}
string EmbedSetAuthor(string data, string name, string url, key icon){
    list tmp = ["name", name];
    if(url!="")tmp+=["url", url];
    if(icon!="")tmp+=["icon_url", "http://texture-service.agni.lindenlab.com/"+(string)icon+"/256x192/"];
    return EmbedSetFields(data, ["author", object(tmp)]);
}
string EmbedAddField(string data, string name, string value, integer inline){
    list tmp = llJson2List(objectKey(data, ["fields"], "[]"));
    return EmbedSetFields(data, ["fields", array(tmp+[object(["name", name, "value", value, "inline", inline])])]);
}

/**************** END DISCORD WEBHOOKS ****************/