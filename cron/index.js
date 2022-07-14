var CronJob = require('cron').CronJob;
var got = require('got');

var CRON_JOB_UPDATE = '48 45 23 * * *';

var CRANDB_REVDEPS =
    'https://crandb.r-pkg.org:6984/cran/_design/internal/_view/' +
    'numrevdeps?group=true';
var CRANLOGS = "https://cranlogs.r-pkg.org/downloads/monthly-totals";
var ES_URL = 'http://elasticsearch:9200/';

var job = new CronJob({
    cronTime: CRON_JOB_UPDATE,
    onTick: (async () => {

	// Reverse dependency numbers
	try {
	    var resp = await got(CRANDB_REVDEPS, { json: true });
	    var rdps = resp.body.rows;
	    console.log('Updating ' + rdps.length + ' package revdeps');
	    for (p in rdps) {
		var pkg = rdps[p].key;
		var num = rdps[p].value;
		var body = { 'doc': { 'revdeps': num } };
		try {
		    await got(ES_URL + 'package/doc/' + pkg + '/_update', {
			method: 'POST', json: true, body: body
		    })
		} catch (error) {
		    console.log('Could not update ' + pkg + ' revdeps: ' +
				error);
		}
	    }
	} catch (error) {
	    console.log('Could not update revdeps: ' + error);
	}

	// Download numbers, relative to the largest
	try {
	    var resp = await got(CRANLOGS, { json: true });
	    var dlds = resp.body;
	    console.log('Updating ' + dlds.length + ' package downloads');
	    for (p in dlds) {
		var pkg = dlds[p].package;
		var num = Number(dlds[p].count);
		var body = { 'doc': { 'downloads': num  } };
		try {
		    await got(ES_URL + 'package/doc/' + pkg + '/_update', {
			method: 'POST', json: true, body: body
		    })
		} catch (error) {
		    console.log('Could not update ' + pkg +
				' downloads: ' + error);
		}
	    }

	} catch (error) {
	    console.log('Could not update download numbers ' + error);
	}

    }),
    start: true,
    runOnInit: true
});

module.exports = job;
