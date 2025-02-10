// Configuration for EIP-712 domain
const domain = {
    name: "HealthcareManagementSystem",
    version: "1",
    chainId: 31337, //  network's chain ID
    verifyingContract: "0x5f5f4A35A3d1aefA3E0f9d5F703496f51686C297", // contract address
};

// Define EIP-712 Types
const types = {
    PatientDataUpdate: [
        { name: "patient", type: "address" },
        { name: "metadataHash", type: "bytes32" },
    ],
    FeedbackSubmission: [
        { name: "hospital", type: "address" },
        { name: "patient", type: "address" },
        { name: "feedback", type: "string" },
    ],
};

// Pinata API credentials
const pinataEndpoint = "https://api.pinata.cloud/pinning/pinJSONToIPFS";
const pinataJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiI0YTk5YWQwYS0zMDNhLTRiMjktYjMyOS02MjAzYjcxNWI4NmMiLCJlbWFpbCI6InNhZGlxYmhhdHRpNjI3QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwaW5fcG9saWN5Ijp7InJlZ2lvbnMiOlt7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6IkZSQTEifSx7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6Ik5ZQzEifV0sInZlcnNpb24iOjF9LCJtZmFfZW5hYmxlZCI6ZmFsc2UsInN0YXR1cyI6IkFDVElWRSJ9LCJhdXRoZW50aWNhdGlvblR5cGUiOiJzY29wZWRLZXkiLCJzY29wZWRLZXlLZXkiOiI2MDYzMWViNTkwN2ViNjM5YmRmMCIsInNjb3BlZEtleVNlY3JldCI6IjFmNWYzZWE5Y2Y2NzRiNDdhMDQ2ZjM5MDlkOWI5ZGM2NDhjNmQ0MTliZDljMDc4NTZlOGIxYzVlM2M3OGE0YTYiLCJleHAiOjE3NzAzMDM3Nzl9.7bVV6JGIRcz3AxMdB_C-LLG6Zk0wELcjdKA15dMEAGU"; //  Pinata JWT

// Function to upload JSON data to IPFS via Pinata
async function uploadToIPFS(data) {
    try {
        const response = await fetch(pinataEndpoint, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${pinataJWT}`,
            },
            body: JSON.stringify(data),
        });
        const result = await response.json();
        if (response.ok) {
            console.log(result);
            return { success: true, ipfsHash: result.IpfsHash };
        } else {
            console.error("Error uploading to IPFS:", result);
            return { success: false, error: result };
        }
    } catch (error) {
        console.error("Error uploading to IPFS:", error);
        return { success: false, error };
    }
}

// Function to sign typed data using EIP-712
async function signTypedData(value, typeName) {
    if (!window.ethereum) {
        console.error("MetaMask not found!");
        return;
    }

    await window.ethereum.request({ method: "eth_requestAccounts" });
    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();

    console.log("Signer Address:", await signer.getAddress());

    // Sign the data
    const signature = await signer.signTypedData(domain, { [typeName]: types[typeName] }, value);
    const structHash = ethers.TypedDataEncoder.hash(domain, { [typeName]: types[typeName] }, value);

    const { v, r, s } = ethers.Signature.from(signature);

    console.log("EIP-712 Structured Hash:", structHash);
    console.log("Signature:", signature);
    console.log("r:", r);
    console.log("s:", s);
    console.log("v:", v);

    return { structHash, r, s, v };
}

// Handle Patient Data Submission
document.getElementById("submitPatientData").addEventListener("click", async () => {
    const patientAddress = document.getElementById("patientAddress").value;
    const patientName = document.getElementById("patientName").value;
    const patientAge = document.getElementById("patientAge").value;

    const patientData = {
        patientAddress,
        patientName,
        patientAge,
    };

    const ipfsResult = await uploadToIPFS(patientData);
    if (ipfsResult.success) {
        const metadataHash = ethers.keccak256(ethers.toUtf8Bytes(ipfsResult.ipfsHash));
        const patientDataUpdate = {
            patient: patientAddress,
            metadataHash,
        };
        await signTypedData(patientDataUpdate, "PatientDataUpdate");
    } else {
        console.error("Failed to upload patient data to IPFS");
    }
});

// Handle Feedback Submission
document.getElementById("submitFeedback").addEventListener("click", async () => {
    const hospitalAddress = document.getElementById("hospitalAddress").value;
    const patientAddress = document.getElementById("patientAddressFeedback").value;
    const feedbackText = document.getElementById("feedbackText").value;

    const feedbackData = {
        hospitalAddress,
        patientAddress,
        feedbackText,
    };

    const ipfsResult = await uploadToIPFS(feedbackData);
    if (ipfsResult.success) {
        const feedbackSubmission = {
            hospital: hospitalAddress,
            patient: patientAddress,
            feedback: ipfsResult.ipfsHash,
        };
        await signTypedData(feedbackSubmission, "FeedbackSubmission");
    } else {
        console.error("Failed to upload feedback to IPFS");
    }
});
