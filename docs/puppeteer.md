# Puppeteer 

Puppeteer requires some specific configuration to work on Alpine, official documentation can be found on the [Puppeteer troubleshooting page](https://pptr.dev/troubleshooting#running-on-alpine).

Information gathered on the specific set up we have is available below.

## Updating Puppeteer

To find the version of puppeteer you need to upgrade to you need to:

1. Locate the version of Chromium that is available to the version of alpine your ruby image is using, this can be found by looking at the `chromium` package version in the Alpine package repository for the version of Alpine you are using. You can find this by going to [this page](https://pkgs.alpinelinux.org/packages?name=chromium&branch=v3.19&repo=&arch=x86_64&origin=&flagged=&maintainer=) and selecting the version of Alpine your ruby image was built off of.
2. Compare this version of Chromium to the available versions of puppeteer listed on the [supported browsers page](https://pptr.dev/supported-browsers) for puppeteer.
3. Update the version of puppeteer in your `package.json` file to match the version that supports the version of Chromium you found in step 1.
4. Run `npm install` to update your `package-lock.json` file with the new version of puppeteer.
5. Update the version of Chromium in the `Dockerfile` to match the version you found in step 1.
6. Rebuild your Docker image to ensure that the new version of Chromium is installed.
7. Test the updated application on a review app to ensure that everything is working correctly with the new version of puppeteer and Chromium by downloading a certificate PDF.

#### What if the version of Chromium available to the Alpine version you are using is not listed on the supported browsers page?

You may need to move to an alternative version of Alpine that has a version of Chromium that is supported by puppeteer. This may involve updating the base image in your Dockerfile to a newer version of Ruby that uses a newer version of Alpine, or switching to a different version of your ruby image that is built off an older version of Alpine that has a supported version of Chromium.

For example, as of writing the Dockerfile is using `ruby:3.4.4-alpine3.20` as alpine 3.20 has a version of Chromium that is supported by puppeteer where as the image `ruby:3.4.4` uses alpine 3.22 which does not have a version of Chromium that is supported by puppeteer.

## Other things to note

### The `--disable-gpu` flag

Right now the setup for puppeteer is being set up with the flag `--disable-gpu`, this is not a core requirement for using puppeteer for our purposes. It is currently in place as workaround to timeout issues beign raised by needing to use alpine 3.20. 

Details on this can be found at the below links:
- https://pptr.dev/troubleshooting#running-on-alpine
- https://github.com/puppeteer/puppeteer/issues/11640
- https://github.com/puppeteer/puppeteer/issues/12637
- https://github.com/puppeteer/puppeteer/issues/12189


