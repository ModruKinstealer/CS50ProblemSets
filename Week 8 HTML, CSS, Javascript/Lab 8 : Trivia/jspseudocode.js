part 1
When a button is pressed
    Check if id "dragon"
        If yes - change color of button to green and print out "Correct!"
        Change background-color: #1188f2; of .btn-group:active
        if no - change color of button to Red and print out "Incorrect!"
            Can use just red or green, red = #ed152f Green= #21cc06

part 2
when submit button is clicked
    check if inputted text = "tenser"
        force inputted text to lowercase
        if yes change color of textbox to green, print out "Correct!"
        if no change color of textbox to red, print out "Incorrect!"



/*
document.querySelector('#btn-group').addEventListener('click', function()
{
    let dragonButton = document.querySelector('btn-group');
    if (dragonButton.innerHTML == 'metallic')
    {
        btn-group.style.backgroundColor == 'green';
        document.querySelector('#dragoncorrect').visibility = visible;
    }
    else
    {
        btn-group.style.backgroundColor == 'red';
        document.querySelector('#dragonwrong').visibility = visible;
    }

});
*/

$('#ID / .Class').css('background-color', '#FF6600');


tried:
let box = document.getElementById("wizbox"); with box.style.backgroundColor = 'green';
    also tried with hex codes for colors
    also tried box.backgroundColor

box.classlist.add("wizInputCorrect");
    css
    .wizInputCorrect {background-color:#21cc06;} Also tried 'green' and 'red'
    .wizInputWrong {background-color:#ed152f;}

let box = window.getComputedStyle(wizbox);
let box = document.getElementById("wizbox");
    let x = window.getComputedStyle(box).display;
    x.style.backgroundColor = 'green';
    box.style.backgroundColor = 'green';

document.input.style.backgroundColor = 'green';

commenting out the correct/incorrect bit to see if that was interfering with the background color

let s = document.querySelector('#wizbox').backgroundColor;
    s = "green";

    let s = document.querySelector('#wizbox').style.backgroundColor

box.classList.toggle("wizInputCorrect");

const cssObj = window.getComputedStyle(box, null);
let bg = cssObj.getPropertyValue("background-color");
bg = 'green';

document.querySelector('#wizbox').classList.add('wizInputCorrect');

