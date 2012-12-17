function requestFullScreen(element) {
    if (element.requestFullScreen) {
        element.requestFullScreen();
    } else if (element.webkitRequestFullScreen) {
        element.webkitRequestFullScreen();
    } else if (element.mozRequestFullScreen) {
        element.mozRequestFullScreen();
    }
}

function requestPointerLock(element) {
    if (element.requestPointerLock) {
        element.requestPointerLock();
    } else if (element.webkitRequestPointerLock) {
        element.webkitRequestPointerLock();
    } else if (element.mozRequestFullScreen) {
        element.mozRequestFullScreen();
    }
}