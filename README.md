# PyChromeless

Python (selenium) Lambda Chromium Automation

PyChromeless allows to automate actions to any webpage from AWS Lambda. The aim of this project is to provide
 the scaffolding for future robot implementations.

## But... how?

All the process is explained [here](https://medium.com/21buttons-tech/crawling-thousands-of-products-using-aws-lambda-80332e259de1). Technologies used are:
* Python 3.6
* Selenium
* [Chrome driver](https://sites.google.com/a/chromium.org/chromedriver/)
* [Small chromium binary](https://github.com/adieuadieu/serverless-chrome/releases)


#### Downloading files

If your goal is to use selenium to download files instead of just scraping content from web pages, then
you will need to specify a `download_dir` when initializing the WebDriverWrapper. Your download location 
should be a writable Lambda directory such as `/tmp`. For example, the first code in 
`lambda_handler` would become 

```python
driver = WebDriverWrapper(download_location='/tmp')
```

This will cause file downloads to automatically download into the `download_location` without 
requiring a confirmation dialog. You might need to sleep the handler until the file is downloaded
since this occurs asynchronously.

In order to download a file from a link that opens in a new tab (i.e. `target='_blank'`) you will need to 
call `enable_download_in_headless_chrome` in your scraping script after navigating to the desired page, but before
clicking to download. This will replace all `target='_blank'` with `target='_self'`. For example:

```python
# Navigate to download page
driver._driver.find_element_by_xpath('//a[@href="/downloads/"]').click()
# Enable headless chrome file download
driver.enable_download_in_headless_chrome()
# Click the download link
driver._driver.find_element_by_class_name("btn").click()
```

## Building

```bash
nix build
```

## Uploading the distributable package

Just add ./result to your serverless package

```yaml
layers:
  bla:  # serverlessjs expose this as BlaLambdaLayer ¯\_"/ _/¯
    name: your-layer-name-at-aws-console
    path: pathToThisFolder/ressult

# we could use it in the same serverless.yaml
# or deploy only this layer and use its arn in other yamls
functions:
  someFunction: 
    # ... rest of your function info
    layers:
      - Ref: BlaLambdaLayer
```

Python example for your function

```python
from pychromeless.webdriver_wrapper import WebDriverWrapper
from selenium.webdriver.common.keys import Keys

def lambda_handler(*args, **kwargs):
    driver = WebDriverWrapper()

    driver.get_url('http://example.com')
    example_text = driver.get_inner_html('(//div//h1)[1]')

    driver.close()

    return example_text

```


## Shouts to
* [Docker lambda](https://github.com/lambci/docker-lambda)
* [Lambdium](https://github.com/smithclay/lambdium)
* [Serverless Chrome repo](https://github.com/adieuadieu/serverless-chrome) & [medium post](https://medium.com/@marco.luethy/running-headless-chrome-on-aws-lambda-fa82ad33a9eb)
* [Chromeless](https://github.com/graphcool/chromeless)

## Contributors
* Jairo Vadillo ([@jairovadillo](https://github.com/jairovadillo))
* Pere Giro ()
* Ricard Falcó ([@ricardfp](https://github.com/ricardfp))
