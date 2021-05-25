<?php


include 'connection.php';
global $conn;


$query = "SELECT * FROM guest_books.books";

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $query = $conn->prepare("SELECT * FROM guest_books.books WHERE title LIKE ?;");
    $book = $_POST['book'];
    $query->bind_param('s',$book);
}

$query->execute();
$query->bind_result($author, $title, $comment, $date, $id);

/* fetch values */
while ($query->fetch()) {
    echo "<p>";
    echo "author: " . $author . " | ";
    echo "title: " . $title . " | ";
    echo "comment: " . $comment . " | ";
    echo "date: " . $date;
    echo "<p><hr>";
}

/* close statement */
$query->close();
