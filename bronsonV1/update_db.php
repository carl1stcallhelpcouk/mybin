#!/usr/bin/env php

<?php

    //
    //
    // PHP script to update the CCTV database with the archive filename and location.
    //
    // Usage.
    //   update_db [option] <parameter>
    //
    // Options.
    //   -h[hotname][<:port>] or --hostname=[hostname][<:port>].  Defaults to time.1stcallhelp.co.uk and port "3306".
    //   -u[username] or --username=[username].  Defaults to "carl".
    //   -p[password] or --password=[password].  Defaults to "letmein123".
    //   -d[database] or --dbname=[database].  Database to use. Defaults to "CCTV".
    //   -t[table] or --table=[table].  Table to update.  Defaults to "security".
    //   -a[archive] or --archive=[archive].  Filename of the archive. 
    //   -l[location] or --location=[location].  Location number of the file.
    //   -f[filename] or --filename=[filename].  Filenames to update.

    ini_set('display_errors', E_ALL); 
    error_reporting(E_ALL);

    $hostname = "time.1stcallhelp.co.uk";
    $username = "carl";
    $password = "letmein123";
    $dbname = "CCTV";
    $table = "security";
    $archive = "delme.tar.gz";
    $location = 1;
    $filename = "/var/lib/motion/02-20160404215801.avi";
    $sql = "";
    
    try 
    {
        $conn = new PDO("mysql:host=$hostname;dbname=$dbname", $username, $password);
        // set the PDO error mode to exception
        $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        $sql = "UPDATE " . $table . " SET archive_file='" . $archive . "', location=" . $location . " WHERE filename='" . $filename . "'";
        echo $sql . "\n";
        
        // Prepare statement
        $stmt = $conn->prepare($sql);

        // execute the query
        $stmt->execute();

        // echo a message to say the UPDATE succeeded
        echo $stmt->rowCount() . " records UPDATED successfully\n";
    }

    catch(PDOException $e)
    {
        echo $sql . "\n" . $e->getMessage() . "\n";
    }

    $conn = null;
?>