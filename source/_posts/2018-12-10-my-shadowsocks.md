---
title: 自用梭子
categories:
  - Work
  - Python
tags:
  - Work
  - Python
  - Proxy
date: 2018-12-10 20:42:15
---

```python
import multiprocessing
import random
import re
import sys
import time

import requests
import shadowsocks.local


def run_shadowsocks(host, port, password, method):
    sys.argv = sys.argv[:1]
    for arg in '-s {} -p {} -k {} -m {}'.format(host, port, password, method).split():
        sys.argv.append(arg)
    shadowsocks.local.main()


def run_from_page():
    print("Downloading servers")
    url = 'https://freeshadowsocks.org/servers'
    print("Servers downloaded")
    text = requests.get(url).text
    lines = [line for line in text.splitlines() if re.match('(\d+/){3}\d+', line)][:18]
    random.shuffle(lines)

    for line in lines:
        _, host, port, password, method, _, _ = line.split()
        print('\nProxy: method={}, password={}, host={}, port={}'.format(method, password, host, port))
        process = multiprocessing.Process(target=run_shadowsocks,
                                          kwargs=dict(host=host, port=port, password=password, method=method))
        process.start()
        try:
            time.sleep(1)
            elapsed = verify_proxy()
            print("Valid proxy with elapsed {}".format(elapsed.microseconds / 1000_000))
            process.join()
        except Exception as e:
            print("Invalid proxy:", e)
            process.terminate()
            print("Terminated.")


def verify_proxy():
    rsp = requests.get('https://google.com', proxies=dict(https='socks5h://localhost:1080'), timeout=5)
    assert rsp.status_code is 200
    return rsp.elapsed


if __name__ == '__main__':
    run_from_page()
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
