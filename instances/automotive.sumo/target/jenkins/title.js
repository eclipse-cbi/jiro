document.title = "Eclipse SUMO - " + document.title;
document.addEventListener('DOMContentLoaded', function() {
    let header = document.querySelector('.page-header__brand');
    if (header) {
        let newLink = document.createElement('a');
        newLink.href = 'https://github.com/eclipse-cbi/jiro/blob/master/instances/automotive.sumo/target/config.json';
        newLink.textContent = 'JCasC Source';
        newLink.style = 'color: white; border-left: 1px solid white; padding-left: 1em; font-size: 1.1em; position: relative; top: 0.2em; left: -1.6em;';
        newLink.target = '_blank';
        newLink.title = 'JIRO JCasC Configuration as Code';
        header.appendChild(newLink);
    } else {
        console.log('Element with class "header" not found.');
    }
});
