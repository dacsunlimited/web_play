JOSN Object Spec
===

# Announcement
    {
      "level": String['success', 'info', 'warning', 'danger'],
      "title": String,
      "message": String,
      "url": String,
      "starts_at": UTC,
      "expires_at": UTC
    }

# sample
    {
      "level":"info", 
      "title":"客户端更新", 
      "message":"最新版PLAY客户端0.1.4已经发布，请前往官网下载", 
      "url":"https://github.com/dacsunlimited/dac_play/releases/tag/pls%2F0.1.3",
      "starts_at":"20150630T12:00:00",
      "expires_at":"2015-07-01T00:00:00"
    }

    wallet_note 5.1 XTS ann.dacplay '{"level":"info", "title":"客户端更新", "message":"最新版PLAY客户端0.1.4已经发布，请前往官网下载", "url":"https://github.com/dacsunlimited/dac_play/releases/tag/pls%2F0.1.3","starts_at":"20150630T12:00:00","expires_at":"2015-07-10T00:00:00"}' false
    
# AdCreative
    {
      version: Integer,
      title: String,
      type: String ['text', 'image'],
      creative: {
        text: String, 
        image: String # only valid when type is image
      },
      link: String
    }

# sample
    {
      "version": 1,
      "title": 'default add 1',
      "type": 'text',
      "creative": {
        "text": "Work Hard, PLAY Hard", 
        "image": ""
      },
      "link": 'http://playfoundation.dev'
    }

# AdBid
    {
      bid: BidID, #OwnerAccount/PositionPriceID
      asset: {
        symbol: String,
        price: Integer #Satoshi
      }
      creative: AdCreative,
      starts_at: UTC
    }
    
# BidID

    OwnerAccount/PositionPriceID
    
# sample

    chat.alice/plain1d

# PositionPrice
    {
      id: String,
      duration: String, #['1d', '1w', '1m']
      price: Integer, #10000000
      asset: String, # PLS
    }

# sample
    {
      "id": "plain1w",
      "duration": "1w",
      "price": 100000000,
      "asset": "PLS"
    }

# AdPosition
轮播类型，
10000PLS,显示1w

    {
      desc: String,
      detail_link: String,
      width: String, #300px, responsive
      height: String, #200px, responsive
      default_creative: AdCreative,
      pricing: [
        PositionPrice,
        PositionPrice,
        PositionPrice
      ]
    }

# sample
    {
      "desc": "display at wallet home page",
      "detail_link": "http://playfoundation.dev",
      "width": "300px",
      "height": "114px",
      "default_creative": {
        "version": 1,
        "title": "default add 1",
        "type": "text",
        "creative": {
          "text": "Work Hard, PLAY Hard", 
          "image": ""
        },
        "link": "http://playfoundation.dev"
      },
      "pricing": [
        {
          "id": "1d",
          "duration": "1d",
          "price": 150,
          "asset": "PLS"
        },
        {
          "id": "1w",
          "duration": "1w",
          "price": 1000,
          "asset": "PLS"
        },
        {
          "id": "1m",
          "duration": "1m",
          "price": 28000,
          "asset": "PLS"
        }
      ]
    }

# public_data
    {
      ...,
      "ad": AdPosition
    }

# sample
    # text type
    {
      "ad": {
        "desc": "display at wallet home page",
        "detail_link": "http://playfoundation.dev",
        "width": "300px",
        "height": "114px",
        "default_creative": {
          "version": 1,
          "title": "default add 1",
          "type": "text",
          "creative": {
            "text": "Work Hard, PLAY Hard", 
            "image": ""
          },
          "link": "http://playfoundation.dev"
        },
        "pricing": [
        {
          "id": "1d",
          "duration": "1d",
          "price": 150,
          "asset": "PLS"
        },
        {
          "id": "1w",
          "duration": "1w",
          "price": 1000,
          "asset": "PLS"
        },
        {
          "id": "1m",
          "duration": "1m",
          "price": 28000,
          "asset": "PLS"
        }
        ]
      }
    }

    wallet_account_update_registration a.alice alice "{\"ad\": {\"desc\": \"display at wallet home page\",\"detail_link\": \"http://playfoundation.dev\",\"width\":\"300px\",\"height\":\"114px\",\"default_creative\": {\"version\": 1,\"title\": \"default add 1\",\"type\": \"text\",\"creative\": {\"text\": \"Work Hard, PLAY Hard\", \"image\": \"\"},\"link\": \"http://playfoundation.dev\"},\"pricing\": [{\"id\": \"1d\",\"duration\": \"1d\",\"price\": 150,\"asset\": \"PLS\"},{\"id\": \"1w\",\"duration\": \"1w\",\"price\": 1000,\"asset\": \"PLS\"},{\"id\": \"1m\",\"duration\": \"1m\",\"price\": 28000,\"asset\": \"PLS\"}]}}"
    
    # image type
    {
      "ad": {
        "desc": "display at wallet home page",
        "detail_link": "http://playfoundation.dev",
        "width": "300px",
        "height": "114px",
        "default_creative": {
          "version": 1,
          "title": "default add 1",
          "type": "image",
          "creative": {
            "text": "Work Hard, PLAY Hard", 
            "image": "http://playfoundation.dev/ad/play.jpg"
          },
          "link": "http://playfoundation.dev"
        },
        "pricing": [
        {
          "id": "1d",
          "duration": "1d",
          "price": 150,
          "asset": "PLS"
        },
        {
          "id": "1w",
          "duration": "1w",
          "price": 1000,
          "asset": "PLS"
        },
        {
          "id": "1m",
          "duration": "1m",
          "price": 28000,
          "asset": "PLS"
        }
        ]
      }
    }
    
    wallet_account_update_registration b.alice alice "{\"ad\": {\"desc\": \"display at wallet home page\",\"detail_link\": \"http://playfoundation.dev\",\"width\": \"300px\",\"height\": \"114px\",\"default_creative\": {\"version\": 1,\"title\": \"default add 1\",\"type\": \"image\",\"creative\": {\"text\": \"Work Hard, PLAY Hard\", \"image\": \"http://playfoundation.dev/ad/play.jpg\"},\"link\": \"http://playfoundation.dev\"},\"pricing\": [{\"id\": \"1d\",\"duration\": \"1d\",\"price\": 150,\"asset\": \"PLS\"},{\"id\": \"1w\",\"duration\": \"1w\",\"price\": 1000,\"asset\": \"PLS\"},{\"id\": \"1m\",\"duration\": \"1m\",\"price\": 28000,\"asset\": \"PLS\"}]}}"

    wallet_account_update_registration c.alice alice "{\"ad\": {\"desc\": \"display at wallet home page\",\"detail_link\": \"http://playfoundation.dev\",\"width\": \"300px\",\"height\": \"114px\",\"default_creative\": {\"version\": 1,\"title\": \"default add 1\",\"type\": \"image\",\"creative\": {\"text\": \"Work Hard, PLAY Hard\", \"image\": \"http://playfoundation.dev/ad/play2.jpg\"},\"link\": \"http://playfoundation.dev\"},\"pricing\": [{\"id\": \"1d\",\"duration\": \"1d\",\"price\": 150,\"asset\": \"PLS\"},{\"id\": \"1w\",\"duration\": \"1w\",\"price\": 1000,\"asset\": \"PLS\"},{\"id\": \"1m\",\"duration\": \"1m\",\"price\": 28000,\"asset\": \"PLS\"}]}}"
    
# TrollBox Ad Position
1PLS per bid + 1 PLS * (message size / 400 bytes + 1) (transaction fee)
    
Ad Position setting

    {
      "ad": {
        "version": 0.1,
        "desc": "Trollbox",
        "detail_link": "",
        "width": "auto",
        "height": "auto",
        "pricing": [
        {
          "id": "plain1m",
          "duration": "1m",
          "price": 100000,
          "asset": "XTS"
        }
        ]
      }
    }
    
    wallet_account_update_registration chat.dacplay dacplay "{\"ad\":{\"version\":0.1,\"desc\":\"Trollbox\",\"detail_link\":\"\",\"width\":\"auto\",\"height\":\"auto\",\"pricing\":[{\"id\":\"plain1m\",\"duration\":\"1m\",\"price\":100000,\"asset\":\"XTS\"}]}}"
    
    
