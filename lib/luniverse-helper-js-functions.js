module.exports = {
  retry: function retry (fn, retriesLeft = 5, interval = 3000, validator = function (response) {
    if (response.result && ['AUDITTED', 'FAILED'].includes(response.data.report.status))
      return true
    else
      return false
  }) {
    return new Promise((resolve, reject) => {
      fn()
        .then((res) => {
          console.log(res);
          if (validator(res))
            return resolve(res);
          else
            throw new Error('AUDIT FAILED');
        })
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
