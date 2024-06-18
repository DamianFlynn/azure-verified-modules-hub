## Cloning the Repository

A clone is a local copy of a repository. Cloning a repository allows you to experiment with changes without affecting the original code. Once you have cloned the repository locally, we can prepare to implement changes.

### Steps to Clone the Repository

1. **Open the terminal.**

   - Launch VSCode, then open the integrated terminal by navigating to `View` > `Terminal` or using the shortcut `` Ctrl + `  ``.

2. **Change the current working directory to the location where you want the cloned directory.**

   - I will host the cloned repository in the `~/Development/InnofactOrg` directory. You can create this directory if it doesn't already exist using the following command:
     ```sh
     mkdir -p ~/Development/InnofactOrg
     ```
   - Navigate to this directory:
     ```sh
     cd ~/Development/InnofactOrg
     ```

3. **Clone the repository.**

   - Use the `git clone` command followed by the repository URL. For example:
     ```sh
     git clone https://github.com/InnofactOrg/azure-verified-solutions.git
     ```
   - This command will create a directory named `azure-verified-solutions` within `~/Development/InnofactOrg` and download all files from the repository into this directory.

4. **Open the cloned repository in VSCode.**

   - You can open the newly cloned repository in VSCode by using the command:
     ```sh
     code ~/Development/InnofactOrg/azure-verified-solutions
     ```

5. **Verify the repository contents.**
   - Ensure that the cloning process was successful by checking the repository contents in VSCode. You should see all the files and directories from the repository.

Once these steps are completed, you will have a local copy of the repository ready for development and experimentation. You can now make changes, commit them to your local repository, and push them to the remote repository when you are ready.

## Next Steps

Now that you have cloned the repository, you can proceed to implement changes. The next step is to prepare correctly for [contributing code/](./contributing-code/).
