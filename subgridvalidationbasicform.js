$(document).ready(function () {
    var list = $(".entity-grid");
    var validationResultsObj = {}; // Object to store validation results for each row
    var formSubmitting = false;

    // Purge validation messages before submitting
    function purgeValidationMessages() {
        $('#validationMessageHeader').remove();
        $("div[id^='validationMessageSubgrid']").remove();
        validationResultsObj = {};
    }

    // Function to generate validation message
    function generateValidationMessage(index, dataId, row, questionText) {
        var validationHeader = $('#validationMessageHeader');
        if (!validationHeader.length) {
            validationHeader = $('<div>', {
                'id': 'validationMessageHeader',
                'class': 'alert alert-danger',
                'role': 'alert'
            }).append('<h2>Validation Errors</h2>');
            $('.form-container').prepend(validationHeader);
        }

        var $validationMessageSubgrid = $('<div>', {
            'id': 'validationMessageSubgrid' + (index),
            'data-id': dataId
        });

        var $ul = $('<ul>', {'role': 'presentation'});
        var $li = $('<li>');
        var $a = $('<a>', {
            'href': '#' + $(".subgrid").attr('id'),
            'referencecontrolid': $(".subgrid").attr('id'),
            'text': questionText + ' must be completed.'
        });

        $li.append($a);
        $ul.append($li);
        $validationMessageSubgrid.append($ul);
        validationHeader.append($validationMessageSubgrid);

        // Scroll to the validation message
        $('html, body').animate({
            scrollTop: validationHeader.offset().top
        }, 'slow');
    }

    // Function to validate document rows
    function validateDocument(row, index) {
        const questionCell = row.find('td[data-attribute="fintrac_question"]');
        const yesNoCell = row.find('td[data-th="Yes or no"]');

        const cellContent = yesNoCell.text().trim();
        const ariaLabel = yesNoCell.attr('aria-label') || '';
        console.log(`Row ${index + 1}: Yes/No cell content: "${cellContent}", aria-label: "${ariaLabel}"`);

        let questionText = questionCell
            ? questionCell.text().replace(/\*/g, '').replace(/\(Required\)/g, '').trim()
            : `Question ${index + 1}`;

        if (yesNoCell.length && 
            (cellContent.toLowerCase() === 'yes' || cellContent.toLowerCase() === 'no' ||
             ariaLabel.toLowerCase() === 'yes' || ariaLabel.toLowerCase() === 'no')) {
            validationResultsObj[index] = true;
            return true;
        } else {
            validationResultsObj[index] = false;
            generateValidationMessage(index, row.data('id'), row, questionText);
            return false;
        }
    }

    // Handle form submission
    function handleFormSubmission(e) {
        e.preventDefault();  // Always prevent default form submission
        e.stopPropagation(); // Stop event from bubbling up
        
        if (formSubmitting) {
            return true; // Allow the form to submit if we've already validated
        }

        purgeValidationMessages();

        var isValid = true;

        $("div.scenarios table.table-striped tbody tr").each(function (i) {
            var row = $(this);
            var isValidRow = validateDocument(row, i);
            if (!isValidRow) {
                isValid = false;
                console.log(`Row ${i + 1} is invalid`);
            } else {
                console.log(`Row ${i + 1} is valid`);
            }
        });

        if (isValid) {
            console.log("Form is valid, submitting...");
            formSubmitting = true;
            // Use the original form submission method
            setTimeout(function() {
                $('#UpdateButton').off('click');
                $('#UpdateButton').click();
            }, 100);
        } else {
            console.log("Form validation failed.");
            $('#UpdateButton').prop('disabled', false); // Re-enable the submit button
        }
        
        return false; // Always return false to ensure the form doesn't submit immediately
    }

    // Attach the form submission handler
    $('#UpdateButton').on('click', function(e) {
        if (!formSubmitting) {
            e.preventDefault();
            e.stopPropagation();
            $(this).prop('disabled', true); // Disable the button to prevent double submission
            handleFormSubmission(e);
            return false;
        }
    });

    // Intercept all form submissions
    $('form').on('submit', function(e) {
        if (!formSubmitting) {
            e.preventDefault();
            e.stopPropagation();
            handleFormSubmission(e);
            return false;
        }
    });

    // Override the default form submission function
    if (typeof WebForm_DoPostBackWithOptions !== 'undefined') {
        var originalWebForm_DoPostBackWithOptions = WebForm_DoPostBackWithOptions;
        WebForm_DoPostBackWithOptions = function (options) {
            if (options.eventTarget.indexOf('UpdateButton') !== -1 && !formSubmitting) {
                handleFormSubmission(new Event('submit'));
                return false;
            }
            return originalWebForm_DoPostBackWithOptions(options);
        };
    }

    // Other initial UI modifications
    list.on("loaded", function () {
        $(".scenarios table.table.table-striped.table-fluid tbody td:eq(3)").hide();
        list.find(".dropdown-menu").css({
            "display": "block",
            "padding": "0px",
            "position": "relative"
        });

        var $anchor = $(".edit-link.launch-modal");
        $anchor.addClass("btn btn-info").css("color", "white");
        list.find(".dropdown-menu").siblings().hide();

        $("td[data-th='Action']").each(function () {
            $(this).css("display", "none");
        });

        $("div.scenarios").each(function () {
            var parentDiv = $(this);
            var tableElement = parentDiv.find("table");

            tableElement.find("tr").each(function (i) {
                var trElement = $(this);
                var tdElements = trElement.find('td[data-th="Yes or no"]');

                if (tdElements.length > 0) {
                    var targetTd = trElement.find("td[data-attribute^='fintrac_question']");
                    var originalText = targetTd.text();
                    var currentUserLanguage = $(".language-link:contains('English')").text().toLowerCase().trim();
                    var renderedText = originalText.split("|");
                    var updatedText = currentUserLanguage === "english" ? renderedText[1] : renderedText[0];
                    var modifiedText = '<b id="#doctype' + i + '_label" style="color:red">*</b>' + updatedText + '<b style="color:red"> (required)</b>';
                    targetTd.html(modifiedText);
                    validationResultsObj[i] = false;
                }
            });
        });
    });
});