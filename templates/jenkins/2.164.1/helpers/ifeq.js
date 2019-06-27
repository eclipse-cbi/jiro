var ifeq = function () {};

ifeq.register = function (Handlebars) {
  Handlebars.registerHelper('ifeq', function(a, b, options) {
    return (a == b) ? options.fn(this) : options.inverse(this);
  });
};

module.exports = ifeq;