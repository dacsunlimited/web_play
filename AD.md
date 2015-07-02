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

    {"level":"info", "title":"客户端更新", "message":"最新版PLAY客户端0.1.4已经发布，请前往官网下载", "url":"https://github.com/dacsunlimited/dac_play/releases/tag/pls%2F0.1.3","starts_at":"20150630T12:00:00","expires_at":"2015-07-01T00:00:00"}

    wallet_note 5.1 XTS alice '{"level":"info", "title":"客户端更新", "message":"最新版PLAY客户端0.1.4已经发布，请前往官网下载", "url":"https://github.com/dacsunlimited/dac_play/releases/tag/pls%2F0.1.3","starts_at":"20150630T12:00:00","expires_at":"2015-07-01T00:00:00"}' false


    wallet_note 5.1 XTS ccc '{"level":"info", "title":"客户端更新", "message":"最新版PLAY客户端0.1.4已经发布，请前往官网下载", "url":"https://github.com/dacsunlimited/dac_play/releases/tag/pls%2F0.1.3","starts_at":"20150630T12:00:00","expires_at":"2015-07-01T00:00:00"}' false

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
      bid: PositionPrice,
      creative: AdCreative,
      starts_at: UTC
    }

# PositionPrice
    {
      id: String,
      duration: String, #['1d', '1w', '1m']
      price: Integer, #100
      asset: String, # PLS
    }

# sample
    {
      "id": "1w",
      "duration": "1w",
      "price": 1000,
      "asset": "PLS"
    }

# AdPosition
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
    