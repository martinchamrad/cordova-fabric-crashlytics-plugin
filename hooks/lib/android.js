var fs = require('fs');
var path = require('path');

var common = require('./common');

module.exports = {
    createPropertiesFile: function() {
        var pluginConfig = common.getPluginConfig('android');

        var crashlyticsPropertiesPath = this._getCrashlyticsPropertiesPath();

        var crashlyticsProperties = '';
        crashlyticsProperties += 'apiKey=' + pluginConfig.apiKey + '\n';
        crashlyticsProperties += 'apiSecret=' + pluginConfig.apiSecret + '\n';

        fs.writeFileSync(crashlyticsPropertiesPath, crashlyticsProperties);
    },

    deletePropertiesFile: function() {
        var crashlyticsPropertiesPath = this._getCrashlyticsPropertiesPath();

        try {
            fs.unlinkSync(crashlyticsPropertiesPath);
        } catch (e) {}
    },

    addBuildGradleExtras: function() {
        var buildGradle = this._readBuildGradle();

        buildGradle +=  '\n' +
                        '// CRASHLYTICS PLUGIN EXTRAS START\n' +
                        'buildscript {\n' +
                        '    repositories {\n' +
                        '        maven { url \'https://maven.fabric.io/public\' }\n' +
                        '    }\n' +
                        '    dependencies {\n' +
                        '        classpath \'io.fabric.tools:gradle:1.+\'\n' +
                        '    }\n' +
                        '}\n' +
                        '\n' +
                        'apply plugin: \'io.fabric\'\n' +
                        'repositories {\n' +
                        '    maven { url \'https://maven.fabric.io/public\' }\n' +
                        '}\n' +
                        'dependencies {\n' +
                        '    compile(\'com.crashlytics.sdk.android:crashlytics:2.5.5@aar\') {\n' +
                        '        transitive = true\n' +
                        '    }\n' +
                        '}\n' +
                        '// CRASHLYTICS PLUGIN EXTRAS END\n';

        this._writeBuildGradle(buildGradle);
    },

    removeBuildGradleExtras: function() {
        var buildGradle = this._readBuildGradle();

        buildGradle = buildGradle.replace(/\n\/\/ CRASHLYTICS PLUGIN EXTRAS START[\s\S]*\/\/ CRASHLYTICS PLUGIN EXTRAS END\n/, '');

        this._writeBuildGradle(buildGradle);
    },

    _getCrashlyticsPropertiesPath: function() {
        return path.join('platforms', 'android', 'crashlytics.properties');
    },

    _readBuildGradle: function() {
        return fs.readFileSync(this._getBuildGradlePath(), 'utf-8');
    },

    _writeBuildGradle: function(buildGradle) {
        fs.writeFileSync(this._getBuildGradlePath(), buildGradle);
    },

    _getBuildGradlePath: function() {
        return path.join('platforms', 'android', 'build.gradle');
    }
};
