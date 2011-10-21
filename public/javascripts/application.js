// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function(){
    apply_field_with_defaults();
    apply_data_hover();
});

function apply_field_with_defaults() {

    $(".field_with_default").each(function(){
        if(this.value == '') {
            this.value = this.title;
            this.style.color = '#a0a0a0';
        }
    }).focus(function(){
        if(this.value == this.title) {
            this.value = '';
            this.style.color = '#000000';
        }
    }).blur(function(){
        if(this.value == '') {
            this.value = this.title;
            this.style.color = '#a0a0a0';
        }
    });

    $("input:image, input:button, input:submit").click(function(){
        $('.field_with_default').each(function(){
            if(this.value == this.title && this.title != ''){
                this.value='';
            }
        });
    });
}


function apply_data_hover() {
    $('img[data-hover]').hover(function() {
        $(this).attr('tmp', $(this).attr('src')).attr('src', $(this).attr('data-hover')).attr('data-hover', $(this).attr('tmp')).removeAttr('tmp');
    }).each(function() {
        $('<img />').attr('src', $(this).attr('data-hover'));
    });;
}
