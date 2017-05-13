var page = require('webpage').create();
                   page.open('http://www.enr-scvotes.org/SC/Oconee/64695/183642/en/md_data.html?cid=0106&', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });
