/* Part 1 function */
function dragonMC(element)
{
    let dCorrect = document.querySelector('#dragoncorrect');
    let dWrong = document.querySelector('#dragonwrong');
    if (element.classList.contains("correct"))
    {
        element.style.backgroundColor = "green";
        dCorrect.style.display = "block";

    }
    else
    {
        element.style.backgroundColor = "red";
        dWrong.style.display = "block";
    }
    window.setTimeout(function(){
        element.style.backgroundColor = "#d9edff";
        dCorrect.style.display = "none";
        dWrong.style.display = "none";
    },500);
}

/*Part 2 function */
function toggleVisibility()
{
    let wizWrongVis = document.querySelector('#wizardwrong');
    let wizCorrectVis = document.querySelector('#wizardcorrect');
    let box = document.getElementById("wizbox");
    if (box.value.toLowerCase() == "tenser")
    {
        wizCorrectVis.style.display = "block";
        box.classList.add('wizInputCorrect');
    }
    else
    {
        wizWrongVis.style.display = "block";
        box.classList.add("wizInputWrong");
    }
}
document.querySelector('form').addEventListener('submit', toggleVisibility);





