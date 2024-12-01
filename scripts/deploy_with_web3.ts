// This script deploys the "GameContract" using the Web3 library.
// Please make sure to compile "./contracts/GameContract.sol" file before running this script.
// Right-click -> "Run" from the context menu of the file to run this script. Shortcut: Ctrl+Shift+S

import { deploy } from './web3-lib'

(async () => {
  try {
    const cz4TokenAddress = '0x464c59c15C752AE6c6f450099174F3f8033488f4';
    const fasuTokenAddress = '0x64d52885d4a37926E1f299A9ab248900248933A6';
    const result = await deploy('GameContract', [cz4TokenAddress, fasuTokenAddress])
    console.log(`GameContract deployed to address: ${result.address}`)
  } catch (e) {
    console.log(e.message)
  }
})()
