module.exports = {
  retry: function retry (fn, validator, retriesLeft = 5, interval = 3000) {
    return new Promise((resolve, reject) => {
      fn()
        .then((res) => {
          console.log(res);
          if (validator(res))
            return resolve(res);
          else
            throw new Error(res.code || res);
        })
        .catch((error) => {
          setTimeout(() => {
            if (retriesLeft === 1) {
              // reject('maximum retries exceeded');
              reject(error);
              return;
            }

            // Passing on "reject" is the important part
            retry(fn, validator, retriesLeft - 1, interval).then(resolve, reject);
          }, interval);
        });
    });
  }
}
