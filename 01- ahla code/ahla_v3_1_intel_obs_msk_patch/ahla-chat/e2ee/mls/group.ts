// Placeholder: MLS group scaffolding.
// Wire to an MLS library (RFC 9420) to manage epochs and secrets.
export async function createMlsGroup(members: string[]) {
  // TODO: integrate an MLS library; this is a stub.
  return { ok: true, members, epoch: 0 };
}
