Copyright (c) 2013, Thomas Rogers / Balloon - Cerberus
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of cellhelp nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THOMAS ROGERS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


Cell Helper, for old Salvage

This addon displays what Pathos cells are still needed in a text box, alters the drop message to display what each Pathos cell does and whether it is still needed, and writes a LL profile (salvage-<playername>.txt when a cell is obtained to pass cells that you have already obtained.

This addon cannot pass things currently in the treasure pool (as LL cannot do that), but any subsequent drop of that cell will be passed. 

In order to manually pass a cell you do not need, you can either obtain it, or type "/echo <me> obtains a --incus cell--." replacing the incus cell with the name of the needed cell. include the "--". Manually editing the LL profile will NOT work, as the addon erases everything in the text document, then rewrites it when a cell is obtained.

If some add/pass functionality is added to Luacore then I'll edit this addon to reflect that. 

Current bugs: While it will say which cells you have, it will also add /Have/ to everything that is dropped, even outside of salvage. I will fix this soon.



