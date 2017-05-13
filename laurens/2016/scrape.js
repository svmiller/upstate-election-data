var page = require('webpage').create();
                   page.open('http://www.enr-scvotes.org/SC/Laurens/64688/183636/en/md_data.html?cid=0106&', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });
