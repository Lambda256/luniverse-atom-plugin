module.exports = {
  retry: function retry (fn, retriesLeft = 5, interval = 3000) {
    return new Promise((resolve, reject) => {
      fn()
        .then(resolve)
        .catch((error) => {
          setTimeout(() => {
            if (retriesLeft === 1) {
              // reject('maximum retries exceeded');
              reject(error);
              return;
            }

            // Passing on "reject" is the important part
            console.log('Lets retry!');
            retry(fn, retriesLeft - 1, interval).then(resolve, reject);
          }, interval);
        });
    });
  }
}
