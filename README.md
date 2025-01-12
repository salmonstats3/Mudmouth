# Mudmouth

Mudmouth is a network diagnostic tool for capturing secure requests on iOS.

## Installation

- TestFlight
  - Comming soon
- TrollStore
  - Required [TrollStore](https://github.com/opa334/TrollStore)
  - Open `apple-magnifier://install?url=https://github.com/salmonstats3/Mudmouth/releases/download/0.1.0/Mudmouth_signed.ipa`
- [Sideloadly](https://sideloadly.io/)

## Usage

- Capturing HTTPS requests with MitM
- Triggering workflows before and after capturing

## URL Schemes

### Add a Profile

```
mudmouth://add?name=<NAME>&url=<URL>&direction=<DIRECTION>&preAction=<ACTION>&preActionUrlScheme=<URL>&postAction=<ACTION>&postActionUrlScheme=<URL>
```

### Capture Requests

```
mudmouth://capture?name=<NAME>
```

### Parameters

| Parameter | Options                   |
| --------- | ------------------------- |
| ACTION    | 0: None<br>1: URL Scheme  |
| DIRECTION | 0: Request<br>1: Response |

## License

Mudmouth is licensed under [the MIT License](/LICENSE).
