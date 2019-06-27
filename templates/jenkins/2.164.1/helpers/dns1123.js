var dns1123 = function () {};

dns1123.register = function (Handlebars) {
  Handlebars.registerHelper('dns1123', function(s, options) {
    return s.toLowerCase().replace(/^[^a-z0-9]/, 'jiro-').replace(/[^-a-z0-9]/g, '-').replace(/[^a-z0-9]$/, '');
  });
};

module.exports = dns1123;