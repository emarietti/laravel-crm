// Agora vai!!
function clickToCall(phoneNumber, userExtension) {
    const encryptedToken = document.querySelector('meta[name="dialer-api-token"]').getAttribute('content');
    const apiToken = atob(encryptedToken); // Descriptografa o token

    fetch('https://api.api4com.com/api/v1/dialer', 
        {
            method: 'POST', 
            headers: {
                'Content-Type': 'application/json', 
                'Authorization': apiToken
            },
            body: JSON.stringify({
                extension: userExtension,
                phone: phoneNumber,
                metadata: {}
            })
        })
    .then(response => response.json())
    .then(data => console.log(data))
    .catch(error => {
        console.error('Error:', error);
        alert('An error occurred while making the call. Please try again.');
    });
}
