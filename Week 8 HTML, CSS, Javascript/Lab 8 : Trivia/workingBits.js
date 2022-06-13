
/* with the following at the end of the body of index.html:
        <script src="trivia.js">
            // TODO: Add code to check answers to questions

        </script>
*/

function toggleVisibility()
{
    let wizWrongVis = document.querySelector('#wizardwrong');
    wizWrongVis.style.display = "block";
    console.log("togglevisibility function ran");

}
document.querySelector('form').addEventListener('submit', toggleVisibility);

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