$(function () {

$('form').on('submit', function (e) {

    e.preventDefault();

    $.ajax({
        type: 'post',
        // url: 'get_books.php',
        url: 'get_books_using_prepared_statement.php',
        data: $('form').serialize(),
        success: function (response) {
            $("#bookList").html(
                response
            )
        }
    });

});

});
