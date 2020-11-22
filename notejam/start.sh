#!/bin/sh

if [ ! -f db/notejam.db ]
then
    node db.js
fi

./bin/www
