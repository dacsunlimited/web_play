JOSN Object Spec
===
ref: http://google-styleguide.googlecode.com/svn/trunk/jsoncstyleguide.xml

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
      "message":"最新版PLAY客户端0.3.3 (Rebalance) 已经发布，请前往官网下载。硬分叉将发生于区块#1340000(约2015年9月3日16点30分)。Latest Client 0.3.3 (Rebalance) has been released. Please visit link to download.  Hard fork is scheduled to take place at block height #1340000 (around 2015-09-03 08:30 UTC).", 
      "url":"https://github.com/dacsunlimited/dac_play/releases",
      "starts_at":"20150901T00:00:00",
      "expires_at":"2015-09-03T08:30:00"
    }

XTS:

    wallet_note 5.1 XTS ann.dacplay '{"level":"info","title":"客户端更新","message":"最新版PLAY客户端0.3.3 (Rebalance) 已经发布，请前往官网下载。硬分叉将发生于区块#1340000(约2015年9月3日16点30分)。Latest Client 0.3.3 (Rebalance) has been released. Please visit link to download.  Hard fork is scheduled to take place at block height #1340000 (around 2015-09-03 08:30 UTC).","url":"https://github.com/dacsunlimited/dac_play/releases","starts_at":"20150901T00:00:00","expires_at":"2015-09-03T08:30:00"}' false

PLS:

    wallet_note 5.1 PLS ann.dacplay '{"level":"info","title":"客户端更新","message":"最新版PLAY客户端0.3.3 (Rebalance) 已经发布，请前往官网下载。硬分叉将发生于区块#1340000(约2015年9月3日16点30分)。Latest Client 0.3.3 (Rebalance) has been released. Please visit link to download.  Hard fork is scheduled to take place at block height #1340000 (around 2015-09-03 08:30 UTC).","url":"https://github.com/dacsunlimited/dac_play/releases","starts_at":"20150901T00:00:00","expires_at":"2015-09-03T08:30:00"}' false

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
      bid: PositionPriceID,
      creative: AdCreative,
      starts_at: UTC
    }
    
# sample
bid on ad.dacplay

    {
      "bid": "1w",
      "creative": {
        "version": 1,
        "title": "play1",
        "type": "image",
        "creative": {
          "image": "http://dacplay.org/ad/play1.jpg"
        },
        "link": "http://dacplay.org/"
      },
      "starts_at": "2015-07-08T00:00:00"
    }
    
    wallet_buy_ad 10000.5 XTS advertiser ad.dacplay '{"bid":"1w","asset":{"symbol":"PLS","price":100000000},"creative":{"version":1,"title":"play1","type":"image","creative":{"image":"http://dacplay.org/ad/play1.jpg"},"link":"http://dacplay.org/"},"starts_at":"2015-07-08T00:00:00"}'
    
    {
      "bid": "1w",
      "creative": {
        "version": 1,
        "title": "play2",
        "type": "image",
        "creative": {
          "image": "http://dacplay.org/ad/play2.jpg"
        },
        "link": "http://dacplay.org/"
      },
      "starts_at": "2015-07-08T00:00:00"
    }

    wallet_buy_ad 10000.5 XTS advertiser ad.dacplay '{"bid":"1w","asset":{"symbol":"PLS","price":100000000},"creative":{"version":1,"title":"play2","type":"image","creative":{"image":"http://dacplay.org/ad/play2.jpg"},"link":"http://dacplay.org/"},"starts_at":"2015-07-10T00:00:00"}'
    wallet_buy_ad 10000.5 XTS advertiser ad.dacplay '{"bid":"1w","asset":{"symbol":"PLS","price":100000000},"creative":{"version":1,"title":"play3","type":"image","creative":{"image":"http://dacplay.org/ad/play3.jpg"},"link":"http://dacplay.org/"},"starts_at":"2015-07-10T00:00:00"}'
    wallet_buy_ad 10000.5 XTS advertiser ad.dacplay '{"bid":"1w","asset":{"symbol":"PLS","price":100000000},"creative":{"version":1,"title":"play4","type":"image","creative":{"image":"http://dacplay.org/ad/play4.jpg"},"link":"http://dacplay.org/"},"starts_at":"2015-07-10T00:00:00"}'
    
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
          "price": 15000000,
          "asset": "PLS"
        },
        {
          "id": "1w",
          "duration": "1w",
          "price": 100000000,
          "asset": "PLS"
        },
        {
          "id": "1m",
          "duration": "1m",
          "price": 2800000000,
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
        "detail_link": "http://dacplay.org/",
        "width": "400px",
        "height": "200px",
        "default_creative": {
          "version": 1,
          "title": "default add 1",
          "type": "text",
          "creative": {
            "text": "Work Hard, PLAY Hard", 
            "image": ""
          },
          "link": "http://dacplay.org/"
        },
        "pricing": [
        {
          "id": "1d",
          "duration": "1d",
          "price": 150000000,
          "asset": "XTS"
        },
        {
          "id": "1w",
          "duration": "1w",
          "price": 1000000000,
          "asset": "XTS"
        },
        {
          "id": "1m",
          "duration": "1m",
          "price": 28000000000,
          "asset": "XTS"
        }
        ]
      }
    }

    wallet_account_update_registration ad.dacplay dacplay "{\"ad\":{\"desc\":\"display at wallet home page\",\"detail_link\":\"http://dacplay.org/\",\"width\":\"400px\",\"height\":\"200px\",\"default_creative\":{\"version\":1,\"title\":\"default add 1\",\"type\":\"text\",\"creative\":{\"text\":\"Work Hard, PLAY Hard\",\"image\":\"\"},\"link\":\"http://dacplay.org/\"},\"pricing\":[{\"id\":\"1d\",\"duration\":\"1d\",\"price\":150000000,\"asset\":\"XTS\"},{\"id\":\"1w\",\"duration\":\"1w\",\"price\":1000000000,\"asset\":\"XTS\"},{\"id\":\"1m\",\"duration\":\"1m\",\"price\":28000000000,\"asset\":\"XTS\"}]}}"
    
    # image type
    {
      "ad": {
        "desc": "display at wallet home page",
        "detail_link": "http://dacplay.org/",
        "width": "400px",
        "height": "200px",
        "default_creative": {
          "version": 1,
          "title": "default add 1",
          "type": "image",
          "creative": {
            "text": "Work Hard, PLAY Hard", 
            "image": "http://dacplay.org/ad/play1.jpg"
          },
          "link": "http://dacplay.org/"
        },
        "pricing": [
        {
          "id": "1d",
          "duration": "1d",
          "price": 150000000,
          "asset": "XTS"
        },
        {
          "id": "1w",
          "duration": "1w",
          "price": 1000000000,
          "asset": "XTS"
        },
        {
          "id": "1m",
          "duration": "1m",
          "price": 28000000000,
          "asset": "XTS"
        }
        ]
      }
    }
    
    wallet_account_update_registration ad.dacplay dacplay "{\"ad\":{\"desc\":\"display at wallet home page\",\"detail_link\":\"http://dacplay.org/\",\"width\":\"400px\",\"height\":\"200px\",\"default_creative\":{\"version\":1,\"title\":\"default add 1\",\"type\":\"image\",\"creative\":{\"text\":\"Work Hard, PLAY Hard\",\"image\":\"http://dacplay.org/ad/play1.jpg\"},\"link\":\"http://dacplay.org/\"},\"pricing\":[{\"id\":\"1d\",\"duration\":\"1d\",\"price\":150000000,\"asset\":\"XTS\"},{\"id\":\"1w\",\"duration\":\"1w\",\"price\":1000000000,\"asset\":\"XTS\"},{\"id\":\"1m\",\"duration\":\"1m\",\"price\":28000000000,\"asset\":\"XTS\"}]}}"
    
# TrollBox Ad Position
1PLS per bid + 1 PLS * (message size / 400 bytes + 1) (transaction fee)
    
Ad Position setting
PLAIN TEXT

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
    
XTS: 

    wallet_account_update_registration chat.dacplay dacplay "{\"ad\":{\"version\":0.1,\"desc\":\"Trollbox\",\"detail_link\":\"\",\"width\":\"auto\",\"height\":\"auto\",\"pricing\":[{\"id\":\"plain1m\",\"duration\":\"1m\",\"price\":100000,\"asset\":\"XTS\"}]}}"

PLS: 

    wallet_account_update_registration chat.dacplay dacplay "{\"ad\":{\"version\":0.1,\"desc\":\"Trollbox\",\"detail_link\":\"\",\"width\":\"auto\",\"height\":\"auto\",\"pricing\":[{\"id\":\"plain1m\",\"duration\":\"1m\",\"price\":100000,\"asset\":\"PLS\"}]}}"

RED PACKET

    {
      "ad": {
        "version": 0.1,
        "desc": "Trollbox",
        "detail_link": "",
        "width": "auto",
        "height": "auto",
        "pricing": [
          {
            "id": "packet1m",
            "duration": "1m",
            "price": 100000,
            "asset": "XTS"
          }
        ]
      }
    }
    
XTS: 

    wallet_account_update_registration chat.dacplay dacplay "{\"ad\":{\"version\":0.1,\"desc\":\"Trollbox\",\"detail_link\":\"\",\"width\":\"auto\",\"height\":\"auto\",\"pricing\":[{\"id\":\"packet1m\",\"duration\":\"1m\",\"price\":100000,\"asset\":\"XTS\"}]}}"

PLS: 

    wallet_account_update_registration chat.dacplay dacplay "{\"ad\":{\"version\":0.1,\"desc\":\"Trollbox\",\"detail_link\":\"\",\"width\":\"auto\",\"height\":\"auto\",\"pricing\":[{\"id\":\"packet1m\",\"duration\":\"1m\",\"price\":100000,\"asset\":\"PLS\"}]}}"

    
COMBINED

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
          },
          {
            "id": "packet1m",
            "duration": "1m",
            "price": 100000,
            "asset": "XTS"
          }
        ]
      }
    }
    
XTS: 

    wallet_account_update_registration chat.dacplay dacplay "{\"ad\":{\"version\":0.1,\"desc\":\"Trollbox\",\"detail_link\":\"\",\"width\":\"auto\",\"height\":\"auto\",\"pricing\":[{\"id\":\"plain1m\",\"duration\":\"1m\",\"price\":100000,\"asset\":\"XTS\"},{\"id\":\"packet1m\",\"duration\":\"1m\",\"price\":100000,\"asset\":\"XTS\"}]}}"
    
PLS: 

    wallet_account_update_registration chat.dacplay dacplay "{\"ad\":{\"version\":0.1,\"desc\":\"Trollbox\",\"detail_link\":\"\",\"width\":\"auto\",\"height\":\"auto\",\"pricing\":[{\"id\":\"plain1m\",\"duration\":\"1m\",\"price\":100000,\"asset\":\"PLS\"},{\"id\":\"packet1m\",\"duration\":\"1m\",\"price\":100000,\"asset\":\"PLS\"}]}}"

# Post Chat Message

PLAINTEXT
    {
      "bidid": "plain1m",
      "creative": {
        "version": 0.1,
        "type": "text",
        "creative": {
          "text": "Hello World"
        }
      },
      "starts_at": "2015-07-09T00:00:00"
    }
    
XTS: 

    wallet_buy_ad 2 XTS alice chat.dacplay {"bidid":"plain1m","creative":{"version":0.1,"type":"text","creative":{"text":"Hello World"}},"starts_at":"2015-07-09T00:00:00"}

PLS: 
    
    wallet_buy_ad 2 PLS alice chat.dacplay {"bidid":"plain1m","creative":{"version":0.1,"type":"text","creative":{"text":"Hello World"}},"starts_at":"2015-07-09T00:00:00"}

REDPACKET

    {
      "bidid": "packet1m",
      "creative": {
        "version": 0.1,
        "type": "packet",
        "creative": {
          "id": "c808295907756b0a546c7ce707c189545d8e1fc4"
        }
      },
      "starts_at": "2015-08-31T00:00:00"
    }
    
XTS: 
    
    wallet_buy_ad 2 XTS alice chat.dacplay {"bidid":"packet1m","creative":{"version":0.1,"type":"packet","creative":{"id":"c808295907756b0a546c7ce707c189545d8e1fc4"}},"starts_at":"2015-08-31T00:00:00"}

PLS: 

    wallet_buy_ad 2 PLS alice chat.dacplay {"bidid":"packet1m","creative":{"version":0.1,"type":"packet","creative":{"id":"c808295907756b0a546c7ce707c189545d8e1fc4"}},"starts_at":"2015-08-31T00:00:00"}