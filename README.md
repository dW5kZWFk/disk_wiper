# disk_eraser


1. udev rule triggers script with every newly attached device (/etc/udev/rules.d/90-usb.rules)
2. script 
        -> starts skdump (disk status)
        -> good state => nwipe + UI status update
        (progress?)
        -> bad state => UI status update

toDo: status update on disconnect (php/ udev)?
