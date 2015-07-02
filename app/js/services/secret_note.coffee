class SecretNote

    # TODO: check message_json type
    # TODO: write message structure protocal
    # @param[type]: public or secret
    # @param[message_json]: serialized message struct json string or json object
    # @param[meta]: meta info
    decode: (type, message_json, meta = {}) =>
        json        = try
            angular.fromJson(message_json)
        catch error
            {title: '', body: message_json}

        json.type = type
        return json

angular.module("app").service("SecretNote", [SecretNote])