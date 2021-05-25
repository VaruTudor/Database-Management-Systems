<?php


include 'connection.php';
global $conn;


$query = "SELECT * FROM guest_books.books";

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $book = $_POST['book'];
    $query = "SELECT * FROM guest_books.books WHERE title LIKE '" . $book . "';";
}

function populateRow($row)
{
    echo "<p>";
    echo "author: " . $row['author'] . " | ";
    echo "title: " . $row['title'] . " | ";
    echo "comment: " . $row['comment'] . " | ";
    echo "date: " . $row['date'];
    echo "<p><hr>";
}

$selectBooksMysqliResult = mysqli_query($conn, $query);

if (mysqli_num_rows($selectBooksMysqliResult) > 0) {
    while ($row = mysqli_fetch_assoc($selectBooksMysqliResult)) {
        populateRow($row);
    }
} else {
    echo "There are no books";
}
